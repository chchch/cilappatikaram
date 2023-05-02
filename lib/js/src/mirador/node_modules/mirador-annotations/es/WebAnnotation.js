"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports["default"] = void 0;

/** */
var WebAnnotation = /*#__PURE__*/function () {
  /** */
  function WebAnnotation(_ref) {
    var canvasId = _ref.canvasId,
        id = _ref.id,
        xywh = _ref.xywh,
        body = _ref.body,
        tags = _ref.tags,
        svg = _ref.svg,
        manifestId = _ref.manifestId;
    this.id = id;
    this.canvasId = canvasId;
    this.xywh = xywh;
    this.body = body;
    this.tags = tags;
    this.svg = svg;
    this.manifestId = manifestId;
  }
  /** */


  var _proto = WebAnnotation.prototype;

  _proto.toJson = function toJson() {
    return {
      body: this.createBody(),
      id: this.id,
      motivation: 'commenting',
      target: this.target(),
      type: 'Annotation'
    };
  }
  /** */
  ;

  _proto.createBody = function createBody() {
    var bodies = [];

    if (this.body) {
      bodies.push({
        type: 'TextualBody',
        value: this.body
      });
    }

    if (this.tags) {
      bodies = bodies.concat(this.tags.map(function (tag) {
        return {
          purpose: 'tagging',
          type: 'TextualBody',
          value: tag
        };
      }));
    }

    if (bodies.length === 1) {
      return bodies[0];
    }

    return bodies;
  }
  /** */
  ;

  _proto.target = function target() {
    var target = this.canvasId;

    if (this.svg || this.xywh) {
      target = {
        source: this.source()
      };
    }

    if (this.svg) {
      target.selector = {
        type: 'SvgSelector',
        value: this.svg
      };
    }

    if (this.xywh) {
      var fragsel = {
        type: 'FragmentSelector',
        value: "xywh=" + this.xywh
      };

      if (target.selector) {
        // add fragment selector
        target.selector = [fragsel, target.selector];
      } else {
        target.selector = fragsel;
      }
    }

    return target;
  }
  /** */
  ;

  _proto.source = function source() {
    var source = this.canvasId;

    if (this.manifest) {
      source = {
        id: this.canvasId,
        partOf: {
          id: this.manifest.id,
          type: 'Manifest'
        },
        type: 'Canvas'
      };
    }

    return source;
  };

  return WebAnnotation;
}();

exports["default"] = WebAnnotation;