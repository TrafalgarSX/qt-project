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

#include "applicationsettings.h"

#include <QDebug>
#include <QFile>
#include <QLoggingCategory>
#include <QVector>

Q_LOGGING_CATEGORY(lcApplicationSettings, "app.applicationsettings")

ApplicationSettings::ApplicationSettings(QObject *parent) :
    QSettings(parent)
{
    qCDebug(lcApplicationSettings) << "Loading settings from" << fileName();
}

QStringList ApplicationSettings::recentFiles() const
{
    if(contains("recentFiles")) {
        return value("recentFiles").toStringList();
    }else {
        return QStringList();
    }
}

void ApplicationSettings::addRecentFile(const QString &filePath)
{
    QStringList files = recentFiles();
    const int existingIndex = files.indexOf(filePath);
    // If it already exists, remove it and move it to the top.
    if (existingIndex != -1)
        files.removeAt(existingIndex);

    // Add the file to the top of the list.
    files.prepend(filePath);

    // Respect the file limit.
    if (files.size() > 20)
        files.removeLast();

    setValue("recentFiles", files);
    emit recentFilesChanged();
}

void ApplicationSettings::clearRecentFiles()
{
    if (recentFiles().isEmpty())
        return;

    setValue("recentFiles", QStringList());
    emit recentFilesChanged();
}

void ApplicationSettings::removeInvalidRecentFiles()
{
    if (!contains("recentFiles"))
        return;

    bool changed = false;
    QStringList files = value("recentFiles").toStringList();
    for (int i = 0; i < files.size(); ) {
        const QString filePath = files.at(i);
        if (filePath.isEmpty() || !QFile::exists(QUrl(filePath).toLocalFile())) {
            files.removeAt(i);
            changed = true;
        } else {
            ++i;
        }
    }

    setValue("recentFiles", files);

    if (changed)
        emit recentFilesChanged();
}

QString ApplicationSettings::displayableFilePath(const QString &filePath) const
{
    return QUrl(filePath).toLocalFile();
}

