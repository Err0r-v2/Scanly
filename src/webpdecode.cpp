#include "webpdecode.h"

#include <webp/decode.h>

bool scanlyLooksLikeWebp(const QByteArray &data)
{
    return data.size() >= 12
        && data.left(4) == "RIFF"
        && data.mid(8, 4) == "WEBP";
}

bool scanlyDecodeWebp(const QByteArray &data, QImage *out)
{
    if (!out || !scanlyLooksLikeWebp(data))
        return false;

    int width = 0;
    int height = 0;
    if (!WebPGetInfo(reinterpret_cast<const uint8_t *>(data.constData()),
                     data.size(), &width, &height)
        || width <= 0 || height <= 0) {
        return false;
    }

    uint8_t *rgba = WebPDecodeRGBA(reinterpret_cast<const uint8_t *>(data.constData()),
                                   data.size(), &width, &height);
    if (!rgba)
        return false;

    const QImage view(rgba, width, height, width * 4, QImage::Format_RGBA8888);
    *out = view.copy();
    WebPFree(rgba);
    return !out->isNull();
}
