import ceylon.io {
    SocketAddress
}
import ceylon.json {
    StringTokenizer
}
import ceylon.json.stream {
    LookAhead,
    StreamParser
}
import ceylon.math.float {
    random
}
import ceylon.net.http {
    get,
    post
}
import ceylon.net.http.server {
    newServer,
    Endpoint,
    Response,
    Request,
    startsWith
}

import org.zalando.ceylon_stups.helloWorldApi.helper {
    ParseError
}
import org.zalando.ceylon_stups.helloWorldApi.model {
    HelloMessage,
    Dices,
    Matrix,
    parseJsonDices
}

// The example is adapted from the ceylon.net documentation.
// https://modules.ceylon-lang.org/repo/1/ceylon/net/1.2.0/module-doc/api/index.html

shared void runServer() {

    Dices rollDices(Integer count) =>
            Dices { results = { (random() * 6).integer + 1 }.repeat(count).sequence(); };
    Matrix rollDiceMatrix(Integer count) =>
            Matrix { results = { { (random() * 6).integer + 1 }.repeat(count).sequence() }.repeat(count).sequence(); };

    //create a HTTP server
    value server = newServer {
        Endpoint {
            path = startsWith("/hello");
            void service(Request request, Response response) {
                print("Serving GET ``request.uri``");
                value result = HelloMessage("Hello World!");
                response.writeString(result.json);
            }
        },
        Endpoint {
            path = startsWith("/diceMatrix");
            void service(Request request, Response response) {
                print("Serving GET ``request.uri``");
                value count = parseInteger(request.parameter("count") else "2") else 2;
                value result = rollDiceMatrix(count);
                response.writeString(result.json);
            }
        },
        Endpoint {
            path = startsWith("/dice");
            void service(Request request, Response response) {
                print("Serving POST ``request.uri``");
                value dices = parseJsonDices(LookAhead(StreamParser(StringTokenizer(request.read()))));
                HelloMessage result;
                if (is ParseError dices) {
                    result = HelloMessage("invalid JSON!");
                    response.responseStatus = 400;
                } else {
                    value count = dices.results.size;
                    print("parsed dice: ``dices.json``, count: ``count``");
                    result = HelloMessage("I parsed ``count`` dice throws, thank you.");
                }
                response.writeString(result.json);
            }
            post
        },
        Endpoint {
            path = startsWith("/dice");
            void service(Request request, Response response) {
                print("Serving GET ``request.uri``");
                value count = parseInteger(request.parameter("count") else "2") else 2;
                value result = rollDices(count);
                response.writeString(result.json);
            }
            get
        }
    };
    //start the server on port 8080
    server.start(SocketAddress("0.0.0.0", 8080));
}

shared void run() {
    runServer();
}
