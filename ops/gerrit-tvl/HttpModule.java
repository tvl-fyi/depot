package su.tvl.gerrit;

import com.google.gerrit.extensions.registration.DynamicSet;
import com.google.gerrit.extensions.webui.JavaScriptPlugin;
import com.google.gerrit.extensions.webui.WebUiPlugin;
import com.google.inject.servlet.ServletModule;

public final class HttpModule extends ServletModule {

  @Override
  protected void configureServlets() {
    DynamicSet.bind(binder(), WebUiPlugin.class).toInstance(new JavaScriptPlugin("tvl.js"));
  }
}
