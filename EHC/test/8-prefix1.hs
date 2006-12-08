-- test prelude, variant 1, to be prefixed to source which request this
-- by means of '-- ## inline test (XXX) --' in first line

data PackedString
data [] a = ''[]'' | a : [a]
data Bool = False | True
data Ordering = LT | EQ | GT

foreign import ccall "primCString2String" fromPackedString :: PackedString -> [Char]
foreign import ccall "primTraceStringExit" traceStringExit :: [Char] -> [Char]

foreign import ccall "primAddInt" (+) :: Int -> Int -> Int
foreign import ccall "primDivInt" (/) :: Int -> Int -> Int
foreign import ccall "primMulInt" (*) :: Int -> Int -> Int
foreign import ccall "primSubInt" (-) :: Int -> Int -> Int
foreign import ccall "primCmpInt" compare :: Int -> Int -> Ordering

seq :: forall a . a -> forall b . b -> b
x `seq` y = letstrict x' = x in y

id x = x

error :: [Char] -> a
error s = traceStringExit s `seq` undefined
undefined :: forall a . a
undefined = error "undefined"