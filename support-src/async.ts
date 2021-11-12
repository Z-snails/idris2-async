interface world {}
type unit = void;

// promise__pure : {0 a : _} -> a -> PrimIO (Promise a)
function async_pure<T>(_ty: undefined, x: T, _w: world): Promise<T> {
  return new Promise((res, _rej) => res(x));
}

// promise__liftIO : {0 a : _} -> PrimIO a -> PrimIO (Promise a)
function async_liftIO<T>(
  _ty: undefined,
  act: (w: world) => T,
  w: world
): Promise<T> {
  return new Promise((res, _rej) => res(act(w)));
}

// promise__async : {0 a : _} -> ((a -> PrimIO ()) -> PrimIO ()) -> PrimIO (Promise a)
function async_async<T>(
  _ty: undefined,
  f: (k: (x: T) => (w: world) => unit) => (w: world) => unit,
  w: world
): Promise<T> {
  return new Promise((res, _rej) => f((x) => (_w) => res(x))(w));
}

// promise__par_app : {0 a, b : _} -> Promise (a -> b) -> Promise a -> PrimIO (Promise b)
function async_par_app<A, B>(
  _ty1: undefined,
  _ty2: undefined,
  fun: Promise<(x: A) => B>,
  arg: Promise<A>
): Promise<B> {
  return Promise.all([fun, arg]).then(([fun, arg]) => fun(arg));
}

// promise__bind :{0 a, b : _} -> Promise a -> (a -> PrimIO (Promise b)) -> PrimIO (Promise b)
function async_bind<A, B>(
  _ty1: undefined,
  _ty2: undefined,
  x: Promise<A>,
  f: (x: A) => (w: world) => Promise<B>,
  w: world
): Promise<B> {
  return x.then((x) => f(x)(w));
}
