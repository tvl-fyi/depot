--------------------------------------------------------------------------------
module Utils where
--------------------------------------------------------------------------------
import Data.Function ((&))
--------------------------------------------------------------------------------

(|>) :: a -> (a -> b) -> b
(|>) = (&)
