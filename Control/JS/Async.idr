module Control.JS.Async

export
data Async : Type -> Type where
    Pure : a -> Async a
    LiftIO : PrimIO a -> Async a
    Asyn : ((a -> PrimIO ()) -> PrimIO ()) -> Async a
    Par : Async (a -> b) -> Async a -> Async b
    Bind : Async a -> (a -> Async b) -> Async b

export
Functor Async where
    map f (Pure x) = Pure $ f x
    map f (LiftIO g) = LiftIO $ \w => let MkIORes x w' = g w in MkIORes (f x) w'
    map f (Asyn g) = Asyn $ \k, w => g (\x, w' => k (f x) w') w
    map f (Par mf mx) = Par (map (f .) mf) mx
    map f (Bind mx g) = Bind mx $ \x => map f $ g x

export
Applicative Async where
    pure = Pure
    mf <*> mx = Bind mf $ \f => map f mx

export
[Parallel] Applicative Async where
    pure = Pure
    (<*>) = Par

export
Monad Async where
    (>>=) = Bind

export
HasIO Async where
    liftIO act = LiftIO (toPrim act)

export %inline
parallel : Traversable t => t (Async a) -> Async (t a)
parallel = sequence @{Parallel}

export %inline
parallelMap : Traversable t => (a -> Async b) -> t a -> Async (t b)
parallelMap = traverse @{%search} @{Parallel}

export %inline
prim__async : ((a -> PrimIO ()) -> PrimIO ()) -> Async a
prim__async = Asyn

export %inline
async : ((a -> IO ()) -> IO ()) -> Async a
async f = prim__async (\k, w => toPrim (f (\x => fromPrim (k x))) w)

data Promise : Type -> Type where [external]

%foreign "javascript:support:pure,async"
promise__pure : {0 a : _} -> a -> PrimIO (Promise a)

%foreign "javascript:support:liftIO,async"
promise__liftIO : {0 a : _} -> PrimIO a -> PrimIO (Promise a)

%foreign "javascript:support:async,async"
promise__async : {0 a : _} -> ((a -> PrimIO ()) -> PrimIO ()) -> PrimIO (Promise a)

%foreign "javascript:support:par_app,async"
promise__par_app : {0 a, b : _} -> Promise (a -> b) -> Promise a -> PrimIO (Promise b)

%foreign "javascript:support:bind,async"
promise__bind :{0 a, b : _} -> Promise a -> (a -> PrimIO (Promise b)) -> PrimIO (Promise b)

export
toPromise : Async a -> IO (Promise a)
toPromise (Pure x) = fromPrim $ promise__pure x
toPromise (LiftIO f) = fromPrim $ promise__liftIO f
toPromise (Asyn f) = fromPrim $ promise__async f
toPromise (Par x y) = fromPrim $ promise__par_app !(toPromise x) !(toPromise y)
toPromise (Bind x f) = fromPrim $ promise__bind !(toPromise x) (\x => toPrim $ toPromise (f x))

export
launch : Async a -> IO ()
launch = ignore . toPromise
