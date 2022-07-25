public class HelloWorldController {

	@AuraEnabled
	public static String getHelloWorld(String name) {
		return 'Hello World, ' + name + ' !';
	}

}