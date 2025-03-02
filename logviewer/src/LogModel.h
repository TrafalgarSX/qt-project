#ifndef LOGMODEL_H
#define LOGMODEL_H

#include <QAbstractItemModel>
#include <QVector>

struct LogEntry {
    QString timestamp;
    QString thread;
    QString level;
    QString message;
};

class LogModel : public QAbstractItemModel
{
    Q_OBJECT
public:
    explicit LogModel(QObject *parent = nullptr);
    ~LogModel();

    enum LogRoles {
        LogMessageRole = Qt::UserRole + 1,
        LogTimestampRole,
        LogThreadRole,
        LogLevelRole
    };

    void loadLogs(const QString &filePath);

    // QAbstractItemModel interface
    QModelIndex index(int row, int column = 0, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &index) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

signals:
    void logsChanged();

private:
    QVector<LogEntry> m_entries;
};

#endif // LOGMODEL_H