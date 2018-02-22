//MIT License
//
//Copyright (c) 2017 Manny Guerrero
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import CircuitBreaker
import Foundation
import HeliumLogger
import LoggerAPI
import Kitura
import SGCircuitBreaker

// MARK: - Application

/// A class that runs a server application.
public final class Application {
    
    // MARK: - Private Instance Attributes
    private let router: Router
    private let mockService: MockService
    private var circuitBreaker: SGCircuitBreaker?
    
    
    // MARK: - Initializers
    
    /// Initializes an instance of `Application`.
    public init() {
        router = Router()
        mockService = MockService()
        setupRoutesSGCircuitBreaker()
        setupLogging()
        setupServer()
    }
    
    
    // MARK: - Public Instance Methods
    
    /// Starts the server.
    public func start() {
        Kitura.run()
    }
}


// MARK: - Private Instance Methods For Setup.
private extension Application {
    
    /// Sets up the routes for SGCircuitBreaker.
    func setupRoutesSGCircuitBreaker() {
        router.all("/") { (request, response, next) in
            response.send("Its Circuit Breaker Time!")
            next()
        }
        router.get("/swiftyguerrero/success") { [weak self] (request, response, next) in
            Log.warning("Will demonstrate success")
            self?.circuitBreaker = SGCircuitBreaker()
            self?.circuitBreaker?.workToPerform = { (circuitBreaker) in
                self?.mockService.success { _, _ in
                    circuitBreaker.success()
                    response.status(.OK).send("Circuit breaker was initially successful! 🎉")
                    next()
                }
            }
            self?.circuitBreaker?.tripped = { _, _ in
                Log.error("Error with success behavior")
                response.status(.internalServerError).send("Circuit breaker tripped during success. 😞")
                next()
            }
            self?.circuitBreaker?.start()
        }
        router.get("/swiftyguerrero/success-delay") { [weak self] (request, response, next) in
            Log.warning("Will demonstrate success after timeout")
            self?.circuitBreaker = SGCircuitBreaker(timeout: 3)
            self?.circuitBreaker?.workToPerform = { (circuitBreaker) in
                guard let strongSelf = self else { return }
                switch circuitBreaker.failureCount {
                case 0:
                    strongSelf.mockService.delayedSuccess(delay: 15) { _, _ in }
                default:
                    strongSelf.mockService.success { _, _ in
                        circuitBreaker.success()
                        response.status(.OK).send("Circuit breaker was successful after retry! 🎉")
                        next()
                    }
                }
            }
            self?.circuitBreaker?.tripped = { _, _ in
                Log.error("Error with success behavior")
                response.status(.internalServerError).send("Circuit breaker tripped during success with delay. 😞")
                next()
            }
            self?.circuitBreaker?.start()
        }
        router.get("/swiftyguerrero/failure") { [weak self] (request, response, next) in
            Log.warning("Will demonstrate failure")
            self?.circuitBreaker = SGCircuitBreaker(maxFailures: 1)
            self?.circuitBreaker?.workToPerform = { [weak self] (circuitBreaker) in
                self?.mockService.failure { _, _ in
                    circuitBreaker.failure()
                }
            }
            self?.circuitBreaker?.tripped = { _, _ in
                response.status(.internalServerError).send("Circuit breaker was tripped from error. 🔥")
                next()
            }
            self?.circuitBreaker?.start()
        }
    }
    
    /// Sets up logging
    func setupLogging() {
        let logger = HeliumLogger()
        logger.colored = true
        Log.logger = logger
    }
    
    /// Sets up the server.
    func setupServer() {
        Kitura.addHTTPServer(onPort: 8090, with: router)
        Log.info("Server will run on port 8090")
        Log.info("REST API can be accessed at http://localhost:8090/")
    }
}
