"use strict";
function async_pure(_ty, x, _w) {
    return new Promise(function (res, _rej) { return res(x); });
}
function async_liftIO(_ty, act, w) {
    return new Promise(function (res, _rej) { return res(act(w)); });
}
function async_async(_ty, f, w) {
    return new Promise(function (res, _rej) { return f(function (x) { return function (_w) { return res(x); }; })(w); });
}
function async_par_app(_ty1, _ty2, fun, arg) {
    return Promise.all([fun, arg]).then(function (_a) {
        var fun = _a[0], arg = _a[1];
        return fun(arg);
    });
}
function async_bind(_ty1, _ty2, x, f, w) {
    return x.then(function (x) { return f(x)(w); });
}
