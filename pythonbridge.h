#ifndef PYTHONBRIDGE_H
#define PYTHONBRIDGE_H

#include <QObject>

class PythonBridge : public QObject
{
    Q_OBJECT
public:
    explicit PythonBridge (QObject* parent = 0) : QObject(parent) {}
    Q_INVOKABLE QString computeWinglets(QString input);
};

#endif // PYTHONBRIDGE_H
