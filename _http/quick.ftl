
<h2 id="quick-start">Quick Start</h2>
<p>
  1. Add <em>avaje-inject</em> and <em>avaje-http-api</em> dependencies.
</p>
<pre content="xml">
<dependency>
  <groupId>io.avaje</groupId>
  <artifactId>avaje-inject</artifactId>
  <version>${avaje-inject.version}</version>
</dependency>

<dependency>
  <groupId>io.avaje</groupId>
  <artifactId>avaje-http-api</artifactId>
  <version>${avaje-http.version}</version>
</dependency>
</pre>

<p>
2. Add the generator module for your desired microframework as a annotation processor.
</p>
<pre content="xml">
  <!-- Annotation processors -->
  <dependency>
    <groupId>io.avaje</groupId>
    <artifactId>avaje-inject-generator</artifactId>
    <version>${avaje-inject.version}</version>
    <scope>provided</scope>
  </dependency>
  <dependency>
    <groupId>io.avaje</groupId>
    <artifactId>avaje-http-{javalin/helidon}-generator</artifactId>
    <version>${avaje-http.version}</version>
    <scope>provided</scope>
    <optional>true</optional>
  </dependency>
</pre>

<p>3. Define a Controller (These APT processors work with both Java and Kotlin.)</p>

<pre content="java">
package org.example.hello;

import io.avaje.http.api.Controller;
import io.avaje.http.api.Get;
import io.avaje.http.api.Path;
import java.util.List;

@Path("/widgets")
@Controller
public class WidgetController {
  private final HelloComponent hello;
  public WidgetController(HelloComponent hello) {
    this.hello = hello;
  }

  @Get("/{id}")
  Widget getById(int id) {
    return new Widget(id, "you got it"+ hello.hello());
  }

  @Get()
  List<Widget> getAll() {
    return List.of(new Widget(1, "Rob"), new Widget(2, "Fi"));
  }

  record Widget(int id, String name){};
}
</pre>

<h2 id=usage>Usage</h2>
<p>
  The natural way to use the generated adapters is to
  get a DI library to find and wire them. This is what the below examples do and
  they use <em>Avaje</em> to do this.
</p>
<p>
  Note that there isn't a requirement to use Avaje for dependency injection.
  Any DI library that can find and wire the generated <em>@Singleton</em> beans can
  be used. You can even use Dagger2 or Guice to wire the controllers if you so desire.
</p>

<h4>Usage with Javalin</h2>

<p>The annotation processor will generate controller classes implementing the WebRoutes interface, which means we can
get all the WebRoutes and register them with Javalin using:
</p>
<pre content="java">
List<WebRoutes> routes = BeanScope.builder().build().list(WebRoutes.class);

Javalin.create()
        .routes(() -> routes.forEach(WebRoutes::registerRoutes))
        .start();
</pre>

<h4>Usage with Helidon SE (4.x)</h2>
<p>
The annotation processor will generate controller classes implementing the Helidon HttpService interface, which we can use
get all the services and register them with the Helidon `HttpRouting`.
</p>

<pre content="java">
List<HttpService> routes = BeanScope.builder().build().list(HttpService.class);
final var builder = HttpRouting.builder();

for (final HttpService httpService : routes) {
   httpService.routing(builder);
}

WebServer.builder()
         .addRouting(builder.build())
         .build()
         .start();
</pre>
