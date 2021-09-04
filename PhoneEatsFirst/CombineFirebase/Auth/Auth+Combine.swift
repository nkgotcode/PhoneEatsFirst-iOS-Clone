//
//  Auth+Combine.swift
//  CombineFirebase
//
//  Created by Kumar Shivang on 22/02/20.
//  Copyright © 2020 Kumar Shivang. All rights reserved.
//

import Combine
import FirebaseAuth

public extension Auth {
  func updateCurrentUser(_ user: FirebaseAuth.User) -> AnyPublisher<Void, Error> {
    Future<Void, Error> { [weak self] promise in
      self?.updateCurrentUser(user) { error in
        guard let error = error else {
          promise(.success(()))
          return
        }
        promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }

  func fetchSignInMethods(forEmail email: String) -> AnyPublisher<[String], Error> {
    Future<[String], Error> { [weak self] promise in
      self?.fetchSignInMethods(forEmail: email) { provider, error in
        guard let error = error else {
          promise(.success(provider ?? []))
          return
        }
        promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }

  func signIn(withEmail email: String, password: String) -> AnyPublisher<AuthDataResult, Error> {
    Future<AuthDataResult, Error> { [weak self] promise in
      self?.signIn(withEmail: email, password: password) { auth, error in
        if let error = error {
          promise(.failure(error))
        } else if let auth = auth {
          promise(.success(auth))
        }
      }
    }.eraseToAnyPublisher()
  }

  func signIn(withEmail email: String, link: String) -> AnyPublisher<AuthDataResult, Error> {
    Future<AuthDataResult, Error> { [weak self] promise in
      self?.signIn(withEmail: email, link: link) { auth, error in
        if let error = error {
          promise(.failure(error))
        } else if let auth = auth {
          promise(.success(auth))
        }
      }
    }.eraseToAnyPublisher()
  }

  func signIn(with credential: AuthCredential) -> AnyPublisher<AuthDataResult, Error> {
    Future<AuthDataResult, Error> { [weak self] promise in
      self?.signIn(with: credential) { auth, error in
        if let error = error {
          promise(.failure(error))
        } else if let auth = auth {
          promise(.success(auth))
        }
      }
    }.eraseToAnyPublisher()
  }

  func signInAnonymously() -> AnyPublisher<AuthDataResult, Error> {
    Future<AuthDataResult, Error> { [weak self] promise in
      self?.signInAnonymously { auth, error in
        if let error = error {
          promise(.failure(error))
        } else if let auth = auth {
          promise(.success(auth))
        }
      }
    }.eraseToAnyPublisher()
  }

  func signIn(withCustomToken token: String) -> AnyPublisher<AuthDataResult, Error> {
    Future<AuthDataResult, Error> { [weak self] promise in
      self?.signIn(withCustomToken: token) { auth, error in
        if let error = error {
          promise(.failure(error))
        } else if let auth = auth {
          promise(.success(auth))
        }
      }
    }.eraseToAnyPublisher()
  }

  func createUser(withEmail email: String,
                  password: String) -> AnyPublisher<AuthDataResult, Error>
  {
    Future<AuthDataResult, Error> { [weak self] promise in
      self?.createUser(withEmail: email, password: password) { auth, error in
        if let error = error {
          promise(.failure(error))
        } else if let auth = auth {
          promise(.success(auth))
        }
      }
    }.eraseToAnyPublisher()
  }

  func comfirmPasswordReset(withCode code: String,
                            newPassword: String) -> AnyPublisher<Void, Error>
  {
    Future<Void, Error> { [weak self] promise in
      self?.confirmPasswordReset(withCode: code, newPassword: newPassword) { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }.eraseToAnyPublisher()
  }

  func checkActionCode(_ code: String) -> AnyPublisher<ActionCodeInfo, Error> {
    Future<ActionCodeInfo, Error> { [weak self] promise in
      self?.checkActionCode(code) { info, error in
        if let error = error {
          promise(.failure(error))
        } else if let info = info {
          promise(.success(info))
        }
      }
    }.eraseToAnyPublisher()
  }

  func verifyPasswordResetCode(_ code: String) -> AnyPublisher<String, Error> {
    Future<String, Error> { [weak self] promise in
      self?.verifyPasswordResetCode(code) { result, error in
        if let error = error {
          promise(.failure(error))
        } else if let result = result {
          promise(.success(result))
        }
      }
    }.eraseToAnyPublisher()
  }

  func applyActionCode(_ code: String) -> AnyPublisher<Void, Error> {
    Future<Void, Error> { [weak self] promise in
      self?.applyActionCode(code) { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }.eraseToAnyPublisher()
  }

  func sendPasswordReset(withEmail email: String) -> AnyPublisher<Void, Error> {
    Future<Void, Error> { [weak self] promise in
      self?.sendPasswordReset(withEmail: email) { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }.eraseToAnyPublisher()
  }

  func sendPasswordReset(withEmail email: String,
                         actionCodeSettings: ActionCodeSettings) -> AnyPublisher<Void, Error>
  {
    Future<Void, Error> { [weak self] promise in
      self?
        .sendPasswordReset(withEmail: email,
                           actionCodeSettings: actionCodeSettings) { error in
          if let error = error {
            promise(.failure(error))
          } else {
            promise(.success(()))
          }
        }
    }.eraseToAnyPublisher()
  }

  func sendSignInLink(withEmail email: String,
                      actionCodeSettings: ActionCodeSettings) -> AnyPublisher<Void, Error>
  {
    Future<Void, Error> { [weak self] promise in
      self?.sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
    }.eraseToAnyPublisher()
  }

  internal struct StateDidChangePublisher: Combine.Publisher {
    typealias Output = FirebaseAuth.User?
    typealias Failure = Never

    private let auth: Auth

    init(_ auth: Auth) {
      self.auth = auth
    }

    func receive<S>(subscriber: S) where S: Subscriber,
      StateDidChangePublisher.Failure == S.Failure, StateDidChangePublisher.Output == S.Input
    {
      let subscription = FirebaseAuth.User.AuthStateDidChangeSubscription(
        subcriber: subscriber,
        auth: auth
      )
      subscriber.receive(subscription: subscription)
    }
  }

  var stateDidChangePublisher: AnyPublisher<FirebaseAuth.User?, Never> {
    StateDidChangePublisher(self)
      .eraseToAnyPublisher()
  }

  fileprivate final class IDTokenDidChangeSubscription<SubscriberType: Subscriber>: Combine
    .Subscription where SubscriberType.Input == Auth
  {
    var handler: IDTokenDidChangeListenerHandle?
    var auth: Auth?

    init(subcriber: SubscriberType, auth: Auth) {
      self.auth = auth
      handler = auth.addIDTokenDidChangeListener { auth, _ in
        _ = subcriber.receive(auth)
      }
    }

    func request(_ demand: Subscribers.Demand) {
      // We do nothing here as we only want to send events when they occur.
      // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }

    func cancel() {
      if let handler = handler {
        auth?.removeIDTokenDidChangeListener(handler)
      }
      handler = nil
      auth = nil
    }
  }

  internal struct IDTokenDidChangePublisher: Combine.Publisher {
    typealias Output = Auth
    typealias Failure = Never

    private let auth: Auth

    init(_ auth: Auth) {
      self.auth = auth
    }

    func receive<S>(subscriber: S) where S: Subscriber,
      IDTokenDidChangePublisher.Failure == S.Failure,
      IDTokenDidChangePublisher.Output == S.Input
    {
      let subscription = IDTokenDidChangeSubscription(subcriber: subscriber, auth: auth)
      subscriber.receive(subscription: subscription)
    }
  }

  var idTokenDidChangePublisher: AnyPublisher<Auth, Never> {
    IDTokenDidChangePublisher(self)
      .eraseToAnyPublisher()
  }
}

private extension FirebaseAuth.User {
  final class AuthStateDidChangeSubscription<SubscriberType: Subscriber>: Combine.Subscription
    where SubscriberType.Input == FirebaseAuth.User?
  {
    var handler: AuthStateDidChangeListenerHandle?
    var auth: Auth?

    init(subcriber: SubscriberType, auth: Auth) {
      self.auth = auth
      handler = auth.addStateDidChangeListener { _, user in
        _ = subcriber.receive(user)
      }
    }

    func request(_ demand: Subscribers.Demand) {
      // We do nothing here as we only want to send events when they occur.
      // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }

    func cancel() {
      if let handler = handler {
        auth?.removeStateDidChangeListener(handler)
      }
      handler = nil
      auth = nil
    }
  }
}
