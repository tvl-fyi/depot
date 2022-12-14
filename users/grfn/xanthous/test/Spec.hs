--------------------------------------------------------------------------------
import           Test.Prelude
--------------------------------------------------------------------------------
import qualified Xanthous.CommandSpec
import qualified Xanthous.Data.EntitiesSpec
import qualified Xanthous.Data.EntityCharSpec
import qualified Xanthous.Data.EntityMap.GraphicsSpec
import qualified Xanthous.Data.EntityMapSpec
import qualified Xanthous.Data.LevelsSpec
import qualified Xanthous.Data.MemoSpec
import qualified Xanthous.Data.NestedMapSpec
import qualified Xanthous.DataSpec
import qualified Xanthous.Entities.CommonSpec
import qualified Xanthous.Entities.RawsSpec
import qualified Xanthous.Entities.RawTypesSpec
import qualified Xanthous.Entities.CharacterSpec
import qualified Xanthous.GameSpec
import qualified Xanthous.Game.StateSpec
import qualified Xanthous.Game.PromptSpec
import qualified Xanthous.Generators.Level.UtilSpec
import qualified Xanthous.MessageSpec
import qualified Xanthous.Messages.TemplateSpec
import qualified Xanthous.OrphansSpec
import qualified Xanthous.RandomSpec
import qualified Xanthous.Util.GraphSpec
import qualified Xanthous.Util.GraphicsSpec
import qualified Xanthous.Util.InflectionSpec
import qualified Xanthous.UtilSpec
--------------------------------------------------------------------------------

main :: IO ()
main = defaultMainWithRerun test

test :: TestTree
test = testGroup "Xanthous"
  [ Xanthous.CommandSpec.test
  , Xanthous.Data.EntitiesSpec.test
  , Xanthous.Data.EntityMap.GraphicsSpec.test
  , Xanthous.Data.EntityMapSpec.test
  , Xanthous.Data.LevelsSpec.test
  , Xanthous.Data.MemoSpec.test
  , Xanthous.Data.NestedMapSpec.test
  , Xanthous.DataSpec.test
  , Xanthous.Entities.CommonSpec.test
  , Xanthous.Entities.RawsSpec.test
  , Xanthous.Entities.CharacterSpec.test
  , Xanthous.Entities.RawTypesSpec.test
  , Xanthous.GameSpec.test
  , Xanthous.Game.StateSpec.test
  , Xanthous.Game.PromptSpec.test
  , Xanthous.Generators.Level.UtilSpec.test
  , Xanthous.MessageSpec.test
  , Xanthous.Messages.TemplateSpec.test
  , Xanthous.OrphansSpec.test
  , Xanthous.RandomSpec.test
  , Xanthous.Util.GraphSpec.test
  , Xanthous.Util.GraphicsSpec.test
  , Xanthous.Util.InflectionSpec.test
  , Xanthous.UtilSpec.test
  , Xanthous.Data.EntityCharSpec.test
  ]
