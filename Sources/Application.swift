public func app() -> Application {
	return Application.getInstance()
}

public class Application {
	public static let VERSION = "0.1.9"
	private static var instance: Application?

	private var serviceProviders = Array<ServiceProvider>()
	public private(set) var booted = false
	public let server: Server

	public convenience init() {
		self.init(serverDriver: SocketServer())
	}

	public init(serverDriver: ServerDriver) {
		self.server = Server(driver: serverDriver)
		self.dynamicType.setInstance(self)
	}

	public static func getInstance() -> Application {
		if let instance = self.instance {
			return instance
		}

		let instance = Application()
		self.setInstance(instance)
		return instance
	}

	public static func setInstance(instance: Application) {
		self.instance = instance
	}

	public func register(providers: [ServiceProvider.Type]) {
		for provider in providers {
			self.register(provider)
		}
	}

	public func register<T: ServiceProvider>(provider: T.Type) -> T {
		if let registered = self.getProvider(provider) {
			return registered
		}

		let provider = provider.init(application: self)
		provider.register()

		if self.booted {
			self.bootProvider(provider)
		}

		return provider
	}

	public func getProvider<T: ServiceProvider>(provider: T.Type) -> T? {
		for value in self.serviceProviders {
			if value.dynamicType == provider {
				return value as? T
			}
		}

		return nil
	}

	public func boot() {
		if self.booted {
			return
		}

		for provider in self.serviceProviders {
			self.bootProvider(provider)
		}

		self.booted = true
	}

	public func bootProvider(provider: ServiceProvider) {
		provider.boot()
	}

}
