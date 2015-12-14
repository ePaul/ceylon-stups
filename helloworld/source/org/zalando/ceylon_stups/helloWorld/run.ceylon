import ceylon.math.float { random }
import ceylon.net.http.server {
	newServer,
	Endpoint,
	Response,
	Request,
	startsWith
}
import ceylon.io {
	SocketAddress
}

shared void runServer() {
	   //create a HTTP server
    value server = newServer {
        //an endpoint, on the path /hello
        Endpoint {
            path = startsWith("/hello");
            //handle requests to this path
            service(Request request, Response response) 
                    => response.writeString("hello world");
        },
        Endpoint {
            path = startsWith("/dice");
            void service(Request request, Response response) =>
                response.writeString("You rolled ``(random()*6).integer+1`` and ``(random()*6).integer+1``");
        }
    };
    //start the server on port 8080
    server.start(SocketAddress("127.0.0.1",8080));
}


"Run the module `org.zalando.ceylon_stups.helloWorld`."
shared void run() {
	runServer();
}