/*
    Copyright 2023, Mitch Curtis

    This file is part of Slate.

    Slate is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Slate is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Slate. If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef APPLICATIONSETTINGS_H
#define APPLICATIONSETTINGS_H

#include <QSettings>
#include <QUrl>

class  ApplicationSettings : public QSettings
{
    Q_OBJECT
    Q_PROPERTY(QStringList recentFiles READ recentFiles NOTIFY recentFilesChanged)

public:
    explicit ApplicationSettings(QObject *parent = nullptr);

    QStringList recentFiles() const;
    Q_INVOKABLE void addRecentFile(const QString &filePath);
    Q_INVOKABLE void clearRecentFiles();
    void removeInvalidRecentFiles();
    // Converts the paths we store ("file:///some-file.png") into a user-facing path.
    Q_INVOKABLE QString displayableFilePath(const QString &filePath) const;


signals:
    void recentFilesChanged();
};

#endif // APPLICATIONSETTINGS_H
