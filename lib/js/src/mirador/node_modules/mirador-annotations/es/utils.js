"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.mapChildren = mapChildren;

var _flatten = _interopRequireDefault(require("lodash/flatten"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

/** */
function mapChildren(layerThing) {
  if (layerThing.children) {
    return (0, _flatten["default"])(layerThing.children.map(function (child) {
      return mapChildren(child);
    }));
  }

  return layerThing;
}