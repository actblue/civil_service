# Version 2.1.0 - September 25, 2019

* `CivilService::Result#errors` now always returns an Errors object even if it hasn't been
  explicitly set.

# Version 2.0.0 - June 26, 2019

* BREAKING CHANGE: The behavior of `CivilService::Service#call` has changed when exceptions are
  raised inside the service.  The `call` method will now catch the exception and return a failing
  result object, with the exception message as an error on `:base`.

  The behavior of `call!` has not changed: a failing result will be raised as a
  `CivilService::ServiceFailure` exception, and an exception thrown inside the service will not be
  caught (and therefore will be raised to the caller).

  The idea of this change is that the behaviors of `call` and `call!` are now predictable: `call`
  will (almost) never raise an exception, whereas `call!` can raise an exception.

  The exception to this rule (pun intended, always intend your puns) is that `call` will not catch
  exceptions that don't inherit from `StandardError`, such as `SystemExit`.  See
  [Honeybadger's explanation](https://www.honeybadger.io/blog/a-beginner-s-guide-to-exceptions-in-ruby/)
  of why this is a good idea.
* `CivilService::Result` now has an additional attribute called `exception`, which can be used to
  retrieve an exception thrown inside a `call` method.
