import Control.JS.Async

%foreign "javascript:lambda:(act, time, w) => setTimeout(() => act(w), time)"
prim__setTimeout : PrimIO () -> Int -> PrimIO ()

wait : Int -> Async ()
wait time = prim__async $ \k => prim__setTimeout (k ()) time

main : IO ()
main = launch $ parallel
    [ wait 3000 *> putStrLn "world"
    , wait 1000 *> putStrLn "hello"
    ]
