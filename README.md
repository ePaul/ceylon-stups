# Ceylon for Stups


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

* to actually push to the correct registry, we need once do `stups configure stups.zalan.do` (or whatever your stups installation is), then `pierone login -u pebermann` (use your user name, of course).

## Stups AWS deploy:

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

Exception log collection doesn't work on the Stups platform.
Maybe this can be emulated using Scalyr (+ ZMON).

## EventLog

It seems like out Eventlog stuff is not yet open-source. So no point in embedding it here. Maybe later.

## Swagger

* There is [`ceylon.json`](https://modules.ceylon-lang.org/repo/1/ceylon/json/1.2.0/module-doc/api/index.html), which can represent JSON as a tree of Object|Array|(primitives), or the other way around.
   This does not support custom type restrictions.

* [This google groups thread](https://groups.google.com/forum/#!topic/ceylon-users/o_7XTLebotY) says there is a JSON←→Object serializer in the works (planned for 1.2.1). That is currently in [alabama](https://github.com/tombentley/alabama).

   Though it looks like Alabama is more for the use case Ceylon → JSON → Ceylon, not a generic Ceylon ←→ JSON serializer.

* A better idea might be to generate the DTO classes from Swagger, and then either
   * see if Jackson/Gson are able to handle that, or
   * also generate a custom serializer/deserializer (possibly based on ceylon.json).

