import ceylon.math.float {
	random
}
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
import com.fasterxml.jackson.databind {
	ObjectMapper,
	SerializationFeature
}
import com.fasterxml.jackson.core {
	JsonFactory
}
import org.zalando.ceylon_stups.helloWorldApi.model {
	HelloMessage,
	Dices
}

// The example is partly copied from the ceylon.net documentation.
// https://modules.ceylon-lang.org/repo/1/ceylon/net/1.2.0/module-doc/api/index.html

shared void runServer() {
	
	Dices rollDices(Integer count) =>
			Dices { results = { (random() * 6).integer + 1 }.repeat(count).sequence(); };
	
	value mapper = ObjectMapper(null of JsonFactory?);
	mapper.configure(SerializationFeature.\iINDENT_OUTPUT, true);
	
	//create a HTTP server
	value server = newServer {
		//an endpoint, on the path /hello
		Endpoint {
			path = startsWith("/hello");
			//handle requests to this path
			void service(Request request, Response response) {
				print("Serving ``request.uri``");
				value result = HelloMessage("Hello World!");
				value bytes = mapper.writeValueAsBytes(result);
				response.writeBytes(bytes.byteArray);
				//response.writeString(result.string);
			}
		},
		Endpoint {
			path = startsWith("/dice");
			void service(Request request, Response response) {
				print("Serving ``request.uri``");
				value count = parseInteger(request.parameter("count") else "2") else 2;
				value result = rollDices(count);
				value bytes = mapper.writeValueAsBytes(result);
				response.writeBytes(bytes.byteArray);
			}
		}
	};
	//start the server on port 8080
	server.start(SocketAddress("0.0.0.0", 8080));
}


"Run the module `org.zalando.ceylon_stups.helloWorld`."
shared void run() {
	runServer();
}
