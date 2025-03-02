#include "LogModel.h"
#include <QFile>
#include <QTextStream>
#include <QRegularExpression>
#include <QDebug>

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
    roles[LogTimestampRole] = "logTimestamp";
    roles[LogMessageRole]   = "logMessage";
    roles[LogThreadRole]    = "logThread";
    roles[LogLevelRole]     = "logLevel";
    return roles;
}

QModelIndex LogModel::index(int row, int column, const QModelIndex &parent) const
{
    if (parent.isValid() || row < 0 || row >= m_entries.size() || column != 0)
        return QModelIndex();
    return createIndex(row, column);
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
    return 1;
}

QVariant LogModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_entries.size())
        return QVariant();

    const LogEntry &entry = m_entries.at(index.row());
    switch (role) {
    case LogTimestampRole:
        return entry.timestamp;
    case LogThreadRole:
        return entry.thread;
    case LogLevelRole:
        return entry.level;
    case LogMessageRole:
        return entry.message;
    default:
        return QVariant();
    }
}

Qt::ItemFlags LogModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

void LogModel::loadLogs(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Cannot open log file:" << filePath;
        return;
    }

    beginResetModel();
    m_entries.clear();

    QTextStream in(&file);
    in.setCodec("UTF-8");

    // Regular expression to parse:
    // [2024-12-18 15:52:26.428][thread 16688][info][: ] etmc log started
    // Group 1: timestamp, Group 2: thread, Group 3: level, Group 4: message.
    QRegularExpression re("^\\[([^\\]]+)\\]\\[([^\\]]+)\\]\\[([^\\]]+)\\]\\[:\\s*\\]\\s*(.*)$");

    while (!in.atEnd()) {
        QString line = in.readLine();
        QRegularExpressionMatch match = re.match(line);
        LogEntry entry;
        if (match.hasMatch()) {
            entry.timestamp = match.captured(1);
            entry.thread    = match.captured(2);
            entry.level     = match.captured(3);
            entry.message   = match.captured(4);
        } else {
            // Fallback: store entire line in message field.
            entry.timestamp = "";
            entry.thread    = "";
            entry.level     = "";
            entry.message   = line;
        }
        m_entries.append(entry);
    }

    file.close();
    endResetModel();
    emit logsChanged();
}