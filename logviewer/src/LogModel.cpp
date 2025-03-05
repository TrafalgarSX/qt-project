#include "LogModel.h"
#include <QFile>
#include <QTextStream>
#include <QRegularExpression>
#include <QDebug>
#include <QUrl>
#include <QGuiApplication>
#include <QClipboard>

LogModel::LogModel(QObject *parent)
    : QAbstractItemModel(parent)
{
}

LogModel::~LogModel()
{
}

QHash<int, QByteArray> LogModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[LogDisplayRole] = "display";
    return roles;
}

QModelIndex LogModel::index(int row, int column, const QModelIndex &parent) const
{
    if (parent.isValid() || row < 0 || row >= m_entries.size() || column < 0 || column >= 7)
        return QModelIndex();
    // 将 row 与 column 存储在内部指针中（如果需要，可传递数据）

    auto *entry = const_cast<LogEntry *>(&m_entries.at(row));
    QString *data = nullptr;

    switch(column){
        case 0:
            data = &entry->timestamp;
            break;
        case 1:
            data = &entry->thread;
            break;
        case 2:
            data = &entry->level;
            break;
        case 3:
            data = &entry->file;
            break;
        case 4:
            data = &entry->line;
            break;
        case 5:
            data = &entry->function;
            break;
        case 6:
            data = &entry->message;
            break;
    }
    return createIndex(row, column, data);
}

QModelIndex LogModel::parent(const QModelIndex &index) const
{
    Q_UNUSED(index)
    return QModelIndex();
}

int LogModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_entries.size();
}

int LogModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return 7;
}

QVariant LogModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_entries.size())
        return QVariant();

    const LogEntry &entry = m_entries.at(index.row());

    if (role == LogDisplayRole) {
        switch (index.column()) {
        case 0:
            return entry.timestamp;
        case 1:
            return entry.thread;
        case 2:
            return entry.level;
        case 3:
            return entry.file;
        case 4:
            return entry.line;
        case 5:
            return entry.function;
        case 6:
            return entry.message;
        }
    }
    return QVariant();
}

QVariant LogModel::headerData(int section, Qt::Orientation orientation,
                        int role) const
{
    if (Qt::Horizontal == orientation && role == LogDisplayRole)
    {
        switch (section) {
        case 0:
            return "timestamp";
        case 1:
            return "thread";
        case 2:
            return "level";
        case 3:
            return "file";
        case 4:
            return "line";
        case 5:
            return "function";
        case 6:
            return "message";
        default:
            return QVariant();
        }
    }else{
        return QVariant();
    }
}


QString LogModel::GetHorizontalHeaderName(int section) const
{
	return headerData(section, Qt::Horizontal, LogDisplayRole).toString();
}

Qt::ItemFlags LogModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

Q_INVOKABLE void LogModel::copyToClipboard(const QModelIndexList &indexes) const
{
    QGuiApplication::clipboard()->setMimeData(mimeData(indexes));
}

Q_INVOKABLE bool LogModel::pasteFromClipboard(const QModelIndex &targetIndex)
{
    const QMimeData *mimeData = QGuiApplication::clipboard()->mimeData();
    // Consider using a QUndoCommand for the following call. It should store
    // the (mime) data for the model items that are about to be overwritten, so
    // that a later call to undo can revert it.
    return dropMimeData(mimeData, Qt::CopyAction, -1, -1, targetIndex);
}

void LogModel::loadLogs(const QString &logFileUrl)
{
    QString logFilePath = QUrl(logFileUrl).toLocalFile();
    QFile file(logFilePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Cannot open log file:" << logFilePath;
        return;
    }

    beginResetModel();
    m_entries.clear();

    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8);

    LogEntry currentEntry;
    bool inEntry = false;

    while (!in.atEnd()) {
        QString line = in.readLine();

        // 如果该行以 '[' 开头，则认为这是新记录的起始行
        if(line.startsWith('[')) {
            // 如果已有正在构建的记录，先保存
            if(inEntry) {
                m_entries.append(currentEntry);
                currentEntry = LogEntry();
            }

            // 解析第一部分：timestamp
            int pos1 = line.indexOf('[');
            int pos2 = line.indexOf(']');
            if(pos1 == -1 || pos2 == -1)
                continue;
            QString timestamp = line.mid(pos1 + 1, pos2 - pos1 - 1);

            // 解析第二部分：thread
            int pos3 = line.indexOf('[', pos2 + 1);
            int pos4 = line.indexOf(']', pos3 + 1);
            if(pos3 == -1 || pos4 == -1)
                continue;
            QString threadContent = line.mid(pos3 + 1, pos4 - pos3 - 1);
            // 取最后一个单词作为线程号
            QStringList threadTokens = threadContent.split(' ', Qt::SkipEmptyParts);
            QString thread = threadTokens.isEmpty() ? "" : threadTokens.last();

            // 解析第三部分：level
            int pos5 = line.indexOf('[', pos4 + 1);
            int pos6 = line.indexOf(']', pos5 + 1);
            if(pos5 == -1 || pos6 == -1)
                continue;
            QString level = line.mid(pos5 + 1, pos6 - pos5 - 1);

            // 解析第四部分：file, line, function
            int pos7 = line.indexOf('[', pos6 + 1);
            int pos8 = line.indexOf(']', pos7 + 1);
            if(pos7 == -1 || pos8 == -1)
                continue;
            QString flf = line.mid(pos7 + 1, pos8 - pos7 - 1).trimmed();
            QString fileName, lineNum, functionName;
            // 如果第四部分为 "[: ]" 或 ":"
            if(flf == ":"
               || flf == ": "         // 根据日志格式，括号中可能只包含冒号和空格
               || flf.isEmpty()) {
                fileName = "";
                lineNum = "";
                functionName = "";
            } else {
                // 假设格式为 "main.cpp:174 operator()"
                int colonIdx = flf.indexOf(':');
                if(colonIdx == -1) {
                    fileName = "";
                    lineNum = "";
                    functionName = "";
                } else {
                    fileName = flf.left(colonIdx).trimmed();
                    int spaceIdx = flf.indexOf(' ', colonIdx + 1);
                    if(spaceIdx == -1) {
                        // 没有函数部分
                        lineNum = flf.mid(colonIdx + 1).trimmed();
                        functionName = "";
                    } else {
                        lineNum = flf.mid(colonIdx + 1, spaceIdx - colonIdx - 1).trimmed();
                        functionName = flf.mid(spaceIdx + 1).trimmed();
                    }
                }
            }

            // 解析第五部分：message —— 从第四部分结束后到行末
            QString message = line.mid(pos8 + 1).trimmed();

            // 将解析结果填充到 currentEntry
            currentEntry.timestamp = timestamp;
            currentEntry.thread = thread;
            currentEntry.level = level;
            currentEntry.file = fileName;
            currentEntry.line = lineNum;
            currentEntry.function = functionName;
            currentEntry.message = message;

            inEntry = true;
        } else {
            // 如果行不以 '[' 开头，则认为是上一条记录的 message 的延续
            if(inEntry) {
                currentEntry.message += "\n" + line;
            }
            else {
                // 如果还未开始新记录，则忽略或另作处理
                continue;
            }
        }
    }

    if (inEntry)
        m_entries.append(currentEntry);

    file.close();
    endResetModel();

}