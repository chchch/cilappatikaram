"use strict";

exports.__esModule = true;
exports["default"] = void 0;

var _miradorAnnotationPlugin = _interopRequireDefault(require("./plugins/miradorAnnotationPlugin"));

exports.miradorAnnotationPlugin = _miradorAnnotationPlugin["default"];

var _externalStorageAnnotationPlugin = _interopRequireDefault(require("./plugins/externalStorageAnnotationPlugin"));

exports.externalStorageAnnotationPlugin = _externalStorageAnnotationPlugin["default"];

var _canvasAnnotationsPlugin = _interopRequireDefault(require("./plugins/canvasAnnotationsPlugin"));

exports.canvasAnnotationsPlugin = _canvasAnnotationsPlugin["default"];

var _annotationCreationCompanionWindow = _interopRequireDefault(require("./plugins/annotationCreationCompanionWindow"));

exports.annotationCreationCompanionWindow = _annotationCreationCompanionWindow["default"];

var _windowSideBarButtonsPlugin = _interopRequireDefault(require("./plugins/windowSideBarButtonsPlugin"));

exports.windowSideBarButtonsPlugin = _windowSideBarButtonsPlugin["default"];

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _default = [_miradorAnnotationPlugin["default"], _externalStorageAnnotationPlugin["default"], _canvasAnnotationsPlugin["default"], _annotationCreationCompanionWindow["default"], _windowSideBarButtonsPlugin["default"]];
exports["default"] = _default;