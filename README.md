# Ceylon for STUPS


*TODO:* finish documentation.

## Local setup (done by me)

* [Install command line Ceylon](http://ceylon-lang.org/download/)
* Install Ceylon-IDE for Eclipse
    * Marketplace → Ceylon → "Ceylon IDE 1.2.0".
    * Alternatively: [use the update site](http://ceylon-lang.org/documentation/1.2/ide/install/).
    
    
* Use the "Introduction to Ceylon Modules" wizard → found problem https://github.com/ceylon/ceylon-ide-eclipse/issues/1652

* http://stackoverflow.com/questions/20045507/how-to-write-web-applications-using-ceylon
* copy example from https://modules.ceylon-lang.org/repo/1/ceylon/net/1.2.0/module-doc/api/index.html, extend it to include dice throwing → works for local.
* To make it work in docker, we need it to listen on IP 0.0.0.0 instead of just 127.0.0.1.

* Create Dockerfile (based on Zalando's OpenJDK image, install Ceylon,
  then add the compiled module and the cached module from the compilation
  so everything is there.
* use `docker run` as the command (with options to use the compiled + modules)

* write build script which combines:
   - cleanup module + cache
   - ceylon compile
   - scm-source
   - docker build
   - (optional) docker push

* to actually push to the correct registry, we need once do `stups configure stups.zalan.do` (or whatever your STUPS installation is), then `pierone login -u pebermann` (use your user name, of course).

## STUPS AWS deploy:

 - get personal account linked to AWS hackweek account
 - `mai login hackweek-PowerUser`
 - `senza init helloworld.yaml` → create helloworld.yaml
 - `senza create helloworld.yaml 6 0.1.7` (means "create stack version 6 
   from version 0.1.7 of the docker container and current version of helloworld.yaml")
 
   → https://ceylon-stups-helloworld-6.hackweek.zalan.do/dice works!
 
 - `senza traffic helloworld.yaml 6 100`
 
   → https://ceylon-stups-helloworld.hackweek.zalan.do/dice works too.
 
## ZMON
 
 * Create check → zmon-checks/hello-check-heartbeat.yaml (use `zmon check-definitions update ...`).
 * Create alert (this currently works only in the ZMON web UI) → result is in zmon-checks/heartbeat-alert.yaml
 
## Scalyr
 
 * create personal account at Scalyr
 * Get invited to the aws+hackweek account, link to your account
 * look at https://www.scalyr.com/help/install-agent-linux,
    copy the API key into senza's definition file helloworld.yaml (as TaupageConfig/scalyr_account_key).

## Exception Monitor

Exception log collection doesn't work on the STUPS platform.
Maybe this can be emulated using Scalyr (+ ZMON).

## EventLog

It seems like out Eventlog stuff is not yet open-source. So no point in embedding it here. Maybe later.

## Swagger

* There is [`ceylon.json`](https://modules.ceylon-lang.org/repo/1/ceylon/json/1.2.0/module-doc/api/index.html), which can represent JSON as a tree of Object|Array|(primitives), or the other way around.
   This does not support custom type restrictions.

* [This google groups thread](https://groups.google.com/forum/#!topic/ceylon-users/o_7XTLebotY) says there is a JSON←→Object serializer in the works (planned for 1.2.1). That is currently in [alabama](https://github.com/tombentley/alabama).

   Though it looks like Alabama is more for the use case Ceylon → JSON → Ceylon, not a generic Ceylon ←→ JSON serializer.

* A better idea might be to generate the DTO classes from Swagger, and then either
   * see if Jackson/Gson are able to handle that.
   * Alternative: also generate a custom serializer/deserializer (possibly based on ceylon.json).

Current state:

* We have a new language `ceylon` in Swagger-codegen (which generates just the model classes
    + module.ceylon/package.ceylon for now).
* Using this, we can generate DTOs from the Swagger API yaml:

       rm -r helloworld/generated-sources && \
         java -jar <path>/swagger-codegen-cli.jar generate \
          -l ceylon \
          -i helloworld/source/org/zalando/ceylon_stups/helloWorld/api/swagger-api.yaml \
          -o helloworld/generated-sources \
          -c helloworld/api-model-generator.json

* Adapted the server code to create instances of those objects and pass them to Jackson's ObjectMapper.
* We need to add dependencies to maven modules.
* When running the server, it immediately crashed with a ClassNotFoundException (about javax.crypto.Cipher)
  in the module loader. Something is broken there. Running with `--flat-classpath` works.
    * I need to file a bug about this.
* Jackson goes into an infinite recursion when serializing a field of type `String?` or `Integer?` (loop of `Character->successor` or `Integer->successor`), same with a `List<Integer>`. Non-optional `String` fields work (they are handled as plain Java Strings internally).
    * maybe we need some plugin for Jackson to be able to handle Ceylon classes.
