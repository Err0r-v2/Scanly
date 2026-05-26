#pragma once

#include <QByteArray>
#include <QImage>

bool scanlyDecodeWebp(const QByteArray &data, QImage *out);
bool scanlyLooksLikeWebp(const QByteArray &data);
