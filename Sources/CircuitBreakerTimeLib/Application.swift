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
    private var swiftyCircuitBreaker: SGCircuitBreaker?
    private var ibmCircuitBreaker: CircuitBreaker<Void, String>?
    
    
    // MARK: - Initializers
    
    /// Initializes an instance of `Application`.
    public init() {
        router = Router()
        mockService = MockService()
        setupRoutesSGCircuitBreaker()
        setupRoutesIBMCircuitBreaker()
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
            Log.warning("Will demonstrate success using SGCircuitBreaker")
            
            // Setup the circuit breaker
            self?.swiftyCircuitBreaker = SGCircuitBreaker()
            
            // Register the work to be performed
            self?.swiftyCircuitBreaker?.workToPerform = { (circuitBreaker) in
                self?.mockService.success { _, _ in
                    circuitBreaker.success()
                    response.status(.OK).send("Circuit breaker was initially successful! 🎉")
                    next()
                }
            }
            
            // Register the handler for when the circuit breaker trips
            self?.swiftyCircuitBreaker?.tripped = { _, _ in
                Log.error("Error with success behavior with SGCircuitBreaker")
                response.status(.internalServerError).send("Circuit breaker tripped during success. 😞")
                next()
            }
            
            // Start the circuit breaker
            self?.swiftyCircuitBreaker?.start()
        }
        router.get("/swiftyguerrero/success-delay") { [weak self] (request, response, next) in
            Log.warning("Will demonstrate success after timeout using SGCircuitBreaker")
            
            // Setup the circuit breaker
            self?.swiftyCircuitBreaker = SGCircuitBreaker(timeout: 3)
            
            // Register the work to be performed
            self?.swiftyCircuitBreaker?.workToPerform = { (circuitBreaker) in
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
            
            // Register the handler for when the circuit breaker trips
            self?.swiftyCircuitBreaker?.tripped = { _, _ in
                Log.error("Error with success delay behavior with SGCircuitBreaker")
                response.status(.internalServerError)
                    .send("Circuit breaker tripped during success with delay. 😞")
                next()
            }
            
            // Start the circuit breaker
            self?.swiftyCircuitBreaker?.start()
        }
        router.get("/swiftyguerrero/failure") { [weak self] (request, response, next) in
            Log.warning("Will demonstrate failure using SGCircuitBreaker")
            
            // Setup the circuit breaker
            self?.swiftyCircuitBreaker = SGCircuitBreaker(maxFailures: 1)
            
            // Register the work to be performed
            self?.swiftyCircuitBreaker?.workToPerform = { [weak self] (circuitBreaker) in
                self?.mockService.failure { _, _ in
                    circuitBreaker.failure()
                }
            }
            
            // Register the handler for when the circuit breaker trips
            self?.swiftyCircuitBreaker?.tripped = { _, _ in
                response.status(.internalServerError).send("Circuit breaker was tripped from error. 🔥")
                next()
            }
            
            // Start the circuit breaker
            self?.swiftyCircuitBreaker?.start()
        }
    }
    
    func setupRoutesIBMCircuitBreaker() {
        router.get("/ibm/success") { [weak self] (request, response, next) in
            Log.warning("Will demonstrate success using IBM circuit breaker")
            
            // Define fallback function. This is used for handling when the circuit breaker trips.
            func circuitBreakerTripped(error: BreakerError, message: String) {
                Log.error("Error with success behavior for IBM circuit breaker")
                response.status(.internalServerError).send("Circuit breaker tripped during success. 😞")
                next()
            }
            
            // Define content function. This is the work that would need to be performed but that could fail.
            // For the `Invocation` object, first parameter is used for the argument used for the work to
            // perform logic and the second parameter is used for the argument used for the fallback fucntion
            func workToPerform(invocation: Invocation<Void, String>) {
                self?.mockService.success { (data, error) in
                    invocation.notifySuccess()
                    response.status(.OK).send("Circuit breaker was initially successful! 🎉")
                    next()
                }
            }
            
            // Create a circuit breaker for each content function and fallback function
            self?.ibmCircuitBreaker = CircuitBreaker(
                name: "Success",
                timeout: 10 * 1000,
                command: workToPerform,
                fallback: circuitBreakerTripped
            )
            
            // Start the circuit breaker
            self?.ibmCircuitBreaker?.run(commandArgs: (), fallbackArgs: "An error has occured!")
            
            // Log a snap shot of the stats
            self?.ibmCircuitBreaker?.logSnapshot()
            
        }
        router.get("/ibm/failure") { [weak self] (request, response, next) in
            Log.warning("Will demonstrate failure using IBM circuit breaker")
            
            // Define fallback function. This is used for handling when the circuit breaker trips.
            func circuitBreakerTripped(error: BreakerError, message: String) {
                response.status(.internalServerError).send("Circuit breaker was tripped from error. 🔥")
                next()
            }
            
            // Define content function. This is the work that would need to be performed but that could fail.
            // For the `Invocation` object, first parameter is used for the argument used for the work to
            // perform logic and the second parameter is used for the argument used for the fallback fucntion
            func workToPerform(invocation: Invocation<Void, String>) {
                self?.mockService.failure { (data, error) in
                    invocation.notifyFailure(error: .defaultError)
                }
            }
            
            // Create a circuit breaker for each content function and fallback function
            self?.ibmCircuitBreaker = CircuitBreaker(
                name: "Failure",
                maxFailures: 1,
                command: workToPerform,
                fallback: circuitBreakerTripped
            )
            
            // Start the circuit breaker
            self?.ibmCircuitBreaker?.run(commandArgs: (), fallbackArgs: "An error has occured!")
            
            // Log a snap shot of the stats
            self?.ibmCircuitBreaker?.logSnapshot()
        }
    }
    
    /// Sets up logging
    func setupLogging() {
        let logger = HeliumLogger()
        Log.logger = logger
    }
    
    /// Sets up the server.
    func setupServer() {
        Kitura.addHTTPServer(onPort: 8090, with: router)
        Log.info("Server will run on port 8090")
        Log.info("REST API can be accessed at http://localhost:8090/")
    }
}
