#include <pybind11/embed.h>
namespace py = pybind11;
#include "pythonbridge.h"

QString PythonBridge::computeWinglets(QString input)
{
    auto winglets = py::module::import("winglets");
    auto inputBytes = input.toUtf8();
    py::str result = winglets.attr("computeWingletsJSON")(inputBytes.data());
    std::string resultStr = result;
    return QString(resultStr.c_str());
}
