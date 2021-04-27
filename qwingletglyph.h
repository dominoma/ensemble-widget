#ifndef QWINGLETGLYPH_H
#define QWINGLETGLYPH_H

#include <QtQuick/QQuickPaintedItem>
#include <QColor>

class QWingletGlyph : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName)
    Q_PROPERTY(QColor color READ color WRITE setColor)

public:
    QWingletGlyph();

    QString name() const;
   void setName(const QString &name);

   QColor color() const;
   void setColor(const QColor &color);

   void paint(QPainter *painter);
private:
    QString m_name;
    QColor m_color;
};

#endif // QWINGLETGLYPH_H
