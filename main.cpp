#include <pybind11/embed.h> // everything needed for embedding
#include <pybind11/numpy.h>
namespace py = pybind11;
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtCharts>

#include "pythonbridge.h"

template <typename T>
py::array vectorToArray(QVector<T> v) {
    return py::array(pybind11::dtype::of<T>(), v.size(), v.data());
}

template <typename T>
QVector<T> arrayToVector(py::array_t<T> a) {
    QVector<T> v(a.size());
    memcpy(v.data(), a.data(), v.size() * sizeof(T));
    return v;
}

int main(int argc, char *argv[])
{
    py::scoped_interpreter guard{};

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    qmlRegisterType<PythonBridge>("com.myself", 1, 0, "PythonBridge");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url); 

    return app.exec();
}
