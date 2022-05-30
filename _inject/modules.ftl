
<h2 id="modules">Modules</h2>

<h3 id="unnamed-module">Unnamed modules</h3>
<p>
  When we don't specify <em>@InjectModule</em> on a module it is an <em>unnamed module</em>.
  In effect a module name is derived from the top most package and that module has no
  <em>provides</em> or <em>requires</em> specified.
</p>
<p>
  For example, if the top level package is determined to be <code>org.foo.coffee</code> then
  the module is called <code>CoffeeModule</code>. In <code>target/generated-sources/annotations</code>
  we will see the generated <code>org.foo.coffee.CoffeeModule</code>.
</p>

<h3 id="single-module">Single module apps</h3>
<p>
  When we are wiring dependencies that are all part of a single jar/module then we don't
  really care about <em>module ordering</em>. All the dependencies that are being injected are known and
  provided by the same jar/module or provided externally.
</p>

<h4>requires - external dependency</h4>
<p>
  We use <code>@InjectModule(requires = ...)</code> to specify an external dependency that will
  be programmatically provided.
</p>
<pre content="java">
// at compile time, allow injection of MyExternalDependency
// ... even though it doesn't exist in this module
@InjectModule(requires = MyExternalDependency.class)
</pre>
<p>
  When compiling the annotation processor checks that dependencies exist or are listed
  in <code>requires</code> (or <code>requiresPackages)</code> meaning that they are
  externally supplied dependencies.
</p>
<p>
  When creating the BeanScope we provide the externally created dependencies using
  <code>bean()</code>. These external dependencies are then injected where needed.
</p>
<pre content="java">

  MyExternalDependency myExternal = ...;

  // create with an externally provided dependency
  final BeanScope scope = BeanScope.builder()
    .bean(MyExternalDependency.class, myExternal)
    .build();
</pre>


<h4>ignoreSingleton</h4>
<p>
  We use <code>@InjectModule(ignoreSingleton = true)</code> in order to specify that we want
  avaje-inject to ignore standard JSR-330 <code>@Singleton</code> - with the expectation
  that another DI library (like Guice) is being used and we want avaje-inject to co-exist
  and ignore anything annotated with <code>@Singleton</code>.
</p>
<pre content="java">
@InjectModule(ignoreSingleton = true)
</pre>
<p>
  When using <code>ignoreSingleton = true</code> we use <a href="#component">@Component</a> instead of
  using <code>@Singleton</code>.
</p>

<h3 id="multi-module">Multi-module apps</h3>
<p>
  When we are wiring dependencies that span multiple jars/modules then we to provide more
  control over the order in which the modules are wired. We provide this control
  by using <code>@InjectModule</code> and the use of <code>provides</code>, and <code>requires</code>
  or <code>requiresPackages</code>.
</p>

<h4>Example - modular coffee app</h4>
<p>
  See example source at <a href="https://github.com/avaje/avaje-inject-examples/tree/main/modular-coffee-app">avaje-inject-examples / modular-coffee-app</a>
</p>

<h5>module 1 - coffee-heater</h5>
<pre content="java">
  @InjectModule(name="coffee-heater", provides = Heater.class)
</pre>

<h5>module 2 - coffee-pump</h5>
<pre content="java">
  @InjectModule(name = "coffee-pump", requires = Heater.class, provides = Pump.class)
</pre>
<p>
  This module expects <code>Heater</code> to be provided by another module. In effect, the
  coffee-heater module must be wired <em>before</em> this module, and it provides the Heater
  that is required when we wire the coffee-pump module.
</p>

<h5>module 3 - coffee-main</h5>
<pre content="java">
  @InjectModule(name = "coffee-main", requires = {Heater.class, Pump.class})
</pre>
<p>
  This module expects <code>Heater</code> and <code>Pump</code> to be provided by other module(s).
  It needs other modules to be wired before and for those modules to provide the Heater and Pump.
</p>
<p>
  avaje-inject determines the order in which to wire the modules based on <code>provides, requires</code>. In this example
  it needs to wire the modules in order of: <em>coffee-heater, coffee-pump and then coffee-main</em>.
</p>
<p>
  That is, in a multi-module app avaje-inject creates one BeanScope per module and needs to
  determine the order in which the modules are wired. It does this using the module <em>provides</em>
  and <em>requires</em>. As the modules are wired, the beans from any previously wired modules are
  available to the module being wired.
</p>

<h3>requires vs requiresPackages</h3>
<p>
  We use either <code>requires</code> OR <code>requiresPackages</code>. Using requires is nice in that
  we explicitly list each external dependency that the module requires BUT this can get onerous when this
  is a really large list. In this case we can use <code>requiresPackages</code> instead and that makes
  the assumption that any dependency under those packages will be provided. So using requiresPackages
  is less strict but more practical when there is a lot of module dependencies.
</p>
<p>
  When we use <code>requiresPackages</code> that means that <code>provides</code> can similarly specify
  a class at the top level, and we don't need to list ALL the provided dependencies.
</p>

<h3 id="inject-module">@InjectModule</h3>

<h4 id="module-name">name</h4>
<p>
  Give the module an explicit name. Otherwise, it is derived from the top level package.
</p>
<h4 id="module-ignoreSingleton">ignoreSingleton</h4>
<p>
  Set this to true in order to specify that we want
  avaje-inject to ignore standard JSR-330 <code>@Singleton</code> with the expectation
  that another DI library (like Guice) is being used and we want avaje-inject to co-exist
  and ignore anything annotated with <code>@Singleton</code>.
</p>

<h4 id="module-provides">provides</h4>
<p>
  List the classes that this module provides. Used to order modules.
</p>
<pre content="java">
@InjectModule(name = "feature-toggle", provides=FeatureToggle.class)
</pre>

<h4 id="module-requires">requires</h4>
<p>
  Defines dependencies that the modules depends on that are provided by another module or manually.
</p>
<pre content="java">
@InjectModule(name = "job-system", requires=FeatureToggle.class)
</pre>
<p>
  In effect this allows the job system components to depend on <code>FeatureToggle</code> with the expectation that
  it will be supplied by another module or supplied manually.
</p>

<h4 id="module-requiresPackages">requiresPackages</h4>
<p>
  If we have a LOT of dependencies provided by another module specifying each of these explicitly in <code>requires</code>
  can get verbose. Instead of doing that we can use <code>requiresPackages</code> to define top level packages, any
  dependency required under top level packages will be expected to be provided by another module.
</p>
<pre content="java">
  // anything at or below the package of Feature is provided externally
  @InjectModule(name = "job-system", requiresPackages=Feature.class)
</pre>

<p>
  <em>avaje-inject</em> uses provides, requires, requiresPackages to determine the order in which the modules are created
  and wired. <em>avaje-inject</em> finds all the modules in the classpath (via Service loader) and then orders the modules
  based on provides, requires, requiresPackages. In the example above the "feature-toggle" module must be wired first,
  and then the  beans it contains are available when wiring the "job-system".
</p>
