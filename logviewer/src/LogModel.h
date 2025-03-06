#ifndef LOGMODEL_H
#define LOGMODEL_H

#include <QtQml>
#include <QAbstractItemModel>
#include <QVector>

struct LogEntry {
    QString timestamp;
    QString thread;
    QString level;
    QString file;
    QString line;
    QString message;
};

class LogModel : public QAbstractItemModel
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit LogModel(QObject *parent = nullptr);
    ~LogModel();

    enum LogRoles {
        LogDisplayRole = Qt::UserRole + 1,
    };

    Q_INVOKABLE void loadLogs(const QString &filePath);
    Q_INVOKABLE void copyToClipboard(const QModelIndexList &indexes) const;
    Q_INVOKABLE bool pasteFromClipboard(const QModelIndex &targetIndex);
	Q_INVOKABLE QString GetHorizontalHeaderName(int section) const;
    // 新增搜索接口，fields为需搜索的字段（例如 "timestamp", "level", ...），若为空则默认搜索全部
    Q_INVOKABLE QModelIndex searchLogs(const QString &query, const QStringList &fields);
    Q_INVOKABLE QModelIndex nextSearchResult(const QModelIndex &currentIndex);
    Q_INVOKABLE QModelIndex prevSearchResult(const QModelIndex &currentIndex);

    // QAbstractItemModel interface
    QModelIndex index(int row, int column = 0, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &index) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int /* section */, Qt::Orientation /* orientation */,
                        int role) const override;
    QMimeData *mimeData(const QModelIndexList &indexes) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const override;

signals:
    void logsChanged();

private:
    QVector<LogEntry> m_entries;
    const int m_columnCount = 6;
    // 新增搜索结果存储变量，存储符合搜索条件的项（以column0的index为代表）
    QVector<QModelIndex> m_searchResult;
};

#endif // LOGMODEL_H