#ifndef LOGMODEL_H
#define LOGMODEL_H

#include <QtQml>
#include <QAbstractItemModel>
#include <QVector>
#include <QSet>
#include <QSqlDatabase>

struct LogEntry {
    QString timestamp;
    QString thread;
    QString level;
    QString file;
    QString line;
    QString message;
};

class LogModel : public QAbstractTableModel
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
    Q_INVOKABLE QModelIndex searchLogs(const QString &query, const QStringList &fields);
    Q_INVOKABLE QModelIndex nextSearchResult();
    Q_INVOKABLE QModelIndex prevSearchResult();

    // 新增：初始化全文搜索数据库
    Q_INVOKABLE bool initializeFTSDatabase();
    // 新增：初始化普通数据库（开启 WAL 模式、创建表和 message 字段索引）
    Q_INVOKABLE bool initializeNormalDatabase();
    // 新增：异步更新普通数据库表项
    Q_INVOKABLE void updateNormalAsync();
    // 修改此处的函数声明，添加 fields 参数（与 searchLogs 保持一致）
    Q_INVOKABLE QModelIndex searchLogsSQL(const QString &query, const QStringList &fields);

    // 新增：后台更新 FTS 索引
    void updateFtsAsync();

    // 新增方法：返回格式化日志详情文本
    Q_INVOKABLE QString getLogDetail(int row) const;

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
    // 新增信号：在后台更新索引完成后触发
    void ftsUpdateFinished();

private: 
    void updateFTS();
    void updateNormal();

private:
    QVector<LogEntry> m_entries;
    const int m_columnCount = 6;
    int m_currentSearchIndex = -1;
    QVector<QModelIndex> m_searchResult;

    // 静态成员变量管理 FTS 数据库
    QSqlDatabase s_ftsDb;
    // 新增：普通数据库连接
    QSqlDatabase s_normalDb;
};

#endif // LOGMODEL_H
