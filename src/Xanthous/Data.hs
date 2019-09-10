{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE TemplateHaskell #-}
--------------------------------------------------------------------------------
-- | Common data types for Xanthous
--------------------------------------------------------------------------------
module Xanthous.Data
  ( Position(..)
  , x
  , y

  , Positioned(..)
  , position
  , positioned
  , loc

    -- *
  , Dimensions'(..)
  , Dimensions
  , HasWidth(..)
  , HasHeight(..)

    -- *
  , Direction(..)
  , opposite
  , move
  , asPosition

    -- *
  , Neighbors(..)
  , edges
  , neighborDirections
  , neighborPositions
  ) where
--------------------------------------------------------------------------------
import           Xanthous.Prelude hiding (Left, Down, Right)
import           Test.QuickCheck (Arbitrary, CoArbitrary, Function)
import           Test.QuickCheck.Arbitrary.Generic
import           Data.Group
import           Brick (Location(Location), Edges(..))
--------------------------------------------------------------------------------
import           Xanthous.Util (EqEqProp(..), EqProp)
import           Xanthous.Orphans ()
--------------------------------------------------------------------------------

data Position where
  Position :: { _x :: Int
             , _y :: Int
             } -> Position
  deriving stock (Show, Eq, Generic, Ord)
  deriving anyclass (Hashable, CoArbitrary, Function)
  deriving EqProp via EqEqProp Position
makeLenses ''Position

instance Arbitrary Position where
  arbitrary = genericArbitrary
  shrink = genericShrink

instance Semigroup Position where
  (Position x₁ y₁) <> (Position x₂ y₂) = Position (x₁ + x₂) (y₁ + y₂)

instance Monoid Position where
  mempty = Position 0 0

instance Group Position where
  invert (Position px py) = Position (-px) (-py)

data Positioned a where
  Positioned :: Position -> a -> Positioned a
  deriving stock (Show, Eq, Ord, Functor, Foldable, Traversable, Generic)
  deriving anyclass (CoArbitrary, Function)

instance Arbitrary a => Arbitrary (Positioned a) where
  arbitrary = Positioned <$> arbitrary <*> arbitrary

position :: Lens' (Positioned a) Position
position = lens
  (\(Positioned pos _) -> pos)
  (\(Positioned _ a) pos -> Positioned pos a)

positioned :: Lens (Positioned a) (Positioned b) a b
positioned = lens
  (\(Positioned _ x') -> x')
  (\(Positioned pos _) x' -> Positioned pos x')

loc :: Iso' Position Location
loc = iso hither yon
  where
    hither (Position px py) = Location (px, py)
    yon (Location (lx, ly)) = Position lx ly

--------------------------------------------------------------------------------

data Dimensions' a = Dimensions
  { _width :: a
  , _height :: a
  }
  deriving stock (Show, Eq, Functor, Generic)
  deriving anyclass (CoArbitrary, Function)
makeFieldsNoPrefix ''Dimensions'

instance Arbitrary a => Arbitrary (Dimensions' a) where
  arbitrary = Dimensions <$> arbitrary <*> arbitrary

type Dimensions = Dimensions' Word

--------------------------------------------------------------------------------

data Direction where
  Up        :: Direction
  Down      :: Direction
  Left      :: Direction
  Right     :: Direction
  UpLeft    :: Direction
  UpRight   :: Direction
  DownLeft  :: Direction
  DownRight :: Direction
  deriving stock (Show, Eq, Generic)

instance Arbitrary Direction where
  arbitrary = genericArbitrary
  shrink = genericShrink

opposite :: Direction -> Direction
opposite Up        = Down
opposite Down      = Up
opposite Left      = Right
opposite Right     = Left
opposite UpLeft    = DownRight
opposite UpRight   = DownLeft
opposite DownLeft  = UpRight
opposite DownRight = UpLeft

move :: Direction -> Position -> Position
move Up        = y -~ 1
move Down      = y +~ 1
move Left      = x -~ 1
move Right     = x +~ 1
move UpLeft    = move Up . move Left
move UpRight   = move Up . move Right
move DownLeft  = move Down . move Left
move DownRight = move Down . move Right

asPosition :: Direction -> Position
asPosition dir = move dir mempty

--------------------------------------------------------------------------------

data Neighbors a = Neighbors
  { _topLeft
  , _top
  , _topRight
  , _left
  , _right
  , _bottomLeft
  , _bottom
  , _bottomRight :: a
  }
  deriving stock (Show, Eq, Ord, Functor, Foldable, Traversable, Generic)
  deriving anyclass (NFData)
makeLenses ''Neighbors

instance Applicative Neighbors where
  pure α = Neighbors
    { _topLeft     = α
    , _top         = α
    , _topRight    = α
    , _left        = α
    , _right       = α
    , _bottomLeft  = α
    , _bottom      = α
    , _bottomRight = α
    }
  nf <*> nx = Neighbors
    { _topLeft     = nf ^. topLeft     $ nx ^. topLeft
    , _top         = nf ^. top         $ nx ^. top
    , _topRight    = nf ^. topRight    $ nx ^. topRight
    , _left        = nf ^. left        $ nx ^. left
    , _right       = nf ^. right       $ nx ^. right
    , _bottomLeft  = nf ^. bottomLeft  $ nx ^. bottomLeft
    , _bottom      = nf ^. bottom      $ nx ^. bottom
    , _bottomRight = nf ^. bottomRight $ nx ^. bottomRight
    }

edges :: Neighbors a -> Edges a
edges neighs = Edges
  { eTop = neighs ^. top
  , eBottom = neighs ^. bottom
  , eLeft = neighs ^. left
  , eRight = neighs ^. right
  }

neighborDirections :: Neighbors Direction
neighborDirections = Neighbors
  { _topLeft     = UpLeft
  , _top         = Up
  , _topRight    = UpRight
  , _left        = Left
  , _right       = Right
  , _bottomLeft  = DownLeft
  , _bottom      = Down
  , _bottomRight = DownRight
  }

neighborPositions :: Position -> Neighbors Position
neighborPositions pos = (`move` pos) <$> neighborDirections
