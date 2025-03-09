#include "LogModel.h"
#include <QFile>
#include <QTextStream>
#include <QRegularExpression>
#include <QDebug>
#include <QUrl>
#include <QGuiApplication>
#include <QClipboard>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QtConcurrent>
#include <QFutureWatcher>

#include "util/utils_timer.hpp"

// 定义静态成员变量
// QSqlDatabase LogModel::s_ftsDb;

LogModel::LogModel(QObject *parent)
    : QAbstractTableModel(parent)
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
    if (parent.isValid() || row < 0 || row >= m_entries.size() || column < 0 || column >= m_columnCount)
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
    return m_columnCount;
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
            return entry.message;
        }
    }
    return QVariant();
}

QVariant LogModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (orientation == Qt::Horizontal && role == LogDisplayRole) {
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
            return "message";
        default:
            return QVariant();
        }
    } else if (orientation == Qt::Vertical) {
        return QString::number(section).rightJustified(6, '0'); // 固定宽度6（用'0'填充）
    }
    return QVariant();
}

Qt::ItemFlags LogModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QMimeData *LogModel::mimeData(const QModelIndexList &indexes) const
{
    QMimeData *mime = new QMimeData;

    if(indexes.length() == 1) {
        QModelIndex idx = indexes.at(0);
        if (idx.isValid()) {
            QVariant dataVariant = this->data(idx, LogDisplayRole);
            mime->setText(dataVariant.toString());
            return mime;
        }
    }

    // 收集所有被选择的行号
    QSet<int> rowSet;
    for (const QModelIndex &idx : indexes) {
        if (idx.isValid())
            rowSet.insert(idx.row());
    }

    // 排序行号
    QList<int> rows = rowSet.values();
    std::sort(rows.begin(), rows.end());

    QStringList lines;
    // 对于每一行，将所有列合并成一行文本，列之间用制表符分隔
    for (int row : rows) {
        QStringList rowContents;
        for (int col = 0; col < m_columnCount; ++col) {
            QModelIndex idx = index(row, col);
            QVariant dataVariant = this->data(idx, LogDisplayRole);
            rowContents << dataVariant.toString();
        }
        lines << rowContents.join("\t");
    }

    QString plainText = lines.join("\n");
    mime->setText(plainText);
    return mime;
}

Q_INVOKABLE void LogModel::copyToClipboard(const QModelIndexList &indexes) const
{
    QGuiApplication::clipboard()->setMimeData(mimeData(indexes));
}

Q_INVOKABLE bool LogModel::pasteFromClipboard(const QModelIndex &targetIndex)
{
    // log table is read-only
    return false;
#if 0
    const QMimeData *mimeData = QGuiApplication::clipboard()->mimeData();
    // Consider using a QUndoCommand for the following call. It should store
    // the (mime) data for the model items that are about to be overwritten, so
    // that a later call to undo can revert it.
    return dropMimeData(mimeData, Qt::CopyAction, -1, -1, targetIndex);
#endif
}

bool LogModel::initializeFTSDatabase()
{
    if (s_ftsDb.isValid()) {
        QSqlQuery dropQuery(s_ftsDb);
        if (!dropQuery.exec("DROP TABLE IF EXISTS logs_fts;")) {
            qWarning() << "Drop logs_fts error:" << dropQuery.lastError().text();
        }
    } else {
        s_ftsDb = QSqlDatabase::addDatabase("QSQLITE", "FTSConnection");
        s_ftsDb.setDatabaseName(":memory:");
        if (!s_ftsDb.open()) {
            qWarning() << "FTS DB open failed:" << s_ftsDb.lastError().text();
            return false;
        }
    }
    QSqlQuery createQuery(s_ftsDb);
    if (!createQuery.exec("CREATE VIRTUAL TABLE logs_fts USING fts5(timestamp, thread, level, file, line, message, tokenize='trigram');")) {
        qWarning() << "FTS table creation error:" << createQuery.lastError().text();
        return false;
    }
    return true;
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
                // 假设格式为 "main.cpp:174"
                int colonIdx = flf.indexOf(':');
                if(colonIdx == -1) {
                    fileName = "";
                    lineNum = "";
                    functionName = "";
                } else {
                    fileName = flf.left(colonIdx).trimmed();
                    lineNum = flf.mid(colonIdx + 1).trimmed();
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

    updateFtsAsync();
}

void LogModel::updateFTS()
{
    // 每次 loadLogs 时更新全文索引：先清空，再插入当前数据
    if (s_ftsDb.isValid()) {
        QSqlQuery clearQuery(s_ftsDb);
        if (!clearQuery.exec("DELETE FROM logs_fts;")) {
            // TODO 这里应该通知 qml 界面
            qWarning() << "Failed to clear logs_fts:" << clearQuery.lastError().text();
        }
        // 开始事务
        if (!s_ftsDb.transaction()) {
            qWarning() << "Failed to start transaction:" << s_ftsDb.lastError().text();
            return;
        }
        for (int row = 0; row < m_entries.size(); row++) {
            const LogEntry &entry = m_entries.at(row);
            QSqlQuery insertQuery(s_ftsDb);
            insertQuery.prepare("INSERT INTO logs_fts(rowid, timestamp, thread, level, file, line, message) "
                                "VALUES (?, ?, ?, ?, ?, ?, ?);");
            insertQuery.addBindValue(row + 1);
            insertQuery.addBindValue(entry.timestamp);
            insertQuery.addBindValue(entry.thread);
            insertQuery.addBindValue(entry.level);
            insertQuery.addBindValue(entry.file);
            insertQuery.addBindValue(entry.line);
            insertQuery.addBindValue(entry.message);
            if (!insertQuery.exec()) {
                qWarning() << "FTS insert error:" << insertQuery.lastError().text();
            }
        }
        if (!s_ftsDb.commit()) {
            qWarning() << "Transaction commit failed:" << s_ftsDb.lastError().text();
        }
    }

}

// 新增：异步更新 FTS 索引方法
void LogModel::updateFtsAsync()
{
    auto *watcher = new QFutureWatcher<void>(this);
    connect(watcher, &QFutureWatcher<void>::finished, this, [this, watcher]() {
         emit ftsUpdateFinished();
         watcher->deleteLater();
    });
    // TODO bug here: if the function is called multiple times, program will crash
    QFuture<void> future = QtConcurrent::run([this]() {
        updateFTS();
    });
    watcher->setFuture(future);
}

// 辅助函数，根据字段名获取对应的日志条目字符串
static QString getFieldValue(const LogEntry &entry, const QString &field)
{
    if(field == "timestamp")
        return entry.timestamp;
    else if(field == "thread")
        return entry.thread;
    else if(field == "level")
        return entry.level;
    else if(field == "file")
        return entry.file;
    else if(field == "line")
        return entry.line;
    else if(field == "message")
        return entry.message;
    return "";
}

QModelIndex LogModel::searchLogs(const QString &query, const QStringList &fields)
{
    m_searchResult.clear();
    m_currentSearchIndex = -1;
    
    if (!s_ftsDb.isValid()) {
        qWarning() << "FTS database is not initialized.";
        return QModelIndex();
    }
    
    // 判断是否需要区分大小写
    bool caseSensitive = true;
    QStringList searchFields = fields;
    if(searchFields.contains("caseInsensitive", Qt::CaseInsensitive)) {
        caseSensitive = false;
        searchFields.removeAll("caseInsensitive");
    }

    // 构造 FTS 查询条件
    QString searchCondition;
    if (searchFields.isEmpty()) {
        // 如果未指定具体列，则默认查询所有字段
        searchCondition = query;
    } else {
        QStringList conditions;
        for (const QString &field : searchFields) {
            // 构造如 message:"xxx" 的条件
            conditions.append(QString(R"(%1:"%2")").arg(field).arg(query));
        }
        searchCondition = conditions.join(" OR ");
    }
    
    QSqlQuery ftsQuery(s_ftsDb);
    ftsQuery.prepare("SELECT rowid FROM logs_fts WHERE logs_fts MATCH ? ORDER BY rowid;");
    ftsQuery.addBindValue(searchCondition);
    if (!ftsQuery.exec()) {
        qWarning() << "FTS query error:" << ftsQuery.lastError().text();
        return QModelIndex();
    }
    
    while (ftsQuery.next()) {
        int rowid = ftsQuery.value(0).toInt();
        QModelIndex idx = index(rowid - 1, 0);
        if (idx.isValid())
            m_searchResult.append(idx);
    }
    
    if (!m_searchResult.isEmpty()) {
        m_currentSearchIndex = 0;
        return m_searchResult.first();
    }
    return QModelIndex();
}

QModelIndex LogModel::nextSearchResult()
{
    if (m_searchResult.isEmpty()) {
        return QModelIndex();
    }

    m_currentSearchIndex = (m_currentSearchIndex + 1) % m_searchResult.size();
    return m_searchResult.at(m_currentSearchIndex);
}

QModelIndex LogModel::prevSearchResult()
{
    if (m_searchResult.isEmpty()) {
        return QModelIndex();
    }

    m_currentSearchIndex = (m_currentSearchIndex - 1 + m_searchResult.size()) % m_searchResult.size();
    return m_searchResult.at(m_currentSearchIndex);
}

QString LogModel::getLogDetail(int row) const
{
    if (row < 0 || row >= m_entries.size())
        return "";
    const LogEntry &entry = m_entries.at(row);
    // 这里将 file 当作 function 字段使用（或自行修改）
    return "Timestamp: " + entry.timestamp + "\n" +
           "Thread: " + entry.thread + "\n" +
           "File: " + entry.file + "\n" +
           "Line: " + entry.line + "\n" +
           "Message:\n" + entry.message;
}

