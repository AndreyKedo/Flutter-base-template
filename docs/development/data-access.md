# APIs, mapping and storage

Read when changing an endpoint, DTO, mapper, repository, cache or datasource. The transport/domain boundary is defined by the [architecture](../architecture/overview.md#normative-requirements); value semantics and collection ownership are defined by the [Dart conventions](../DEVELOPMENT.md#value-types-and-collection-ownership).

## Normative requirements

- An API in `lib/feature/<feature>/api/` or `lib/core/api/` extends [RestApi](../../lib/core/network/rest_api.dart). Use its URL construction, headers and error handling instead of creating a parallel HTTP layer.
- Encode/decode JSON through [appJsonCodec](../../lib/core/utils/json_parser.dart); `Response.bodyAsJson()` provides shared parsing for object responses. The endpoint determines the response shape: do not treat an array as an object without checking.
- Place DTOs in `dto/`, conversions in `mapper/`, and domain types in `entity/`. A repository contract in `repository/` accepts/returns domain types; its implementation connects the API, mapper and any required datasource.
- Validate the transport shape during decoding and the response's semantic consistency where the domain context is known. Do not disguise a contract violation as a partially successful result.
- Add a datasource only when local storage is needed. Define the cache/fallback policy for the specific operation rather than automatically importing it from another feature. Local fallback availability must follow from the contract and the actual presence of data.

## Current implementation

[RestApi](../../lib/core/network/rest_api.dart) receives an `AppHttpClient` and `baseUri`, and provides HTTP methods, header merging, status checking and connection-error conversion. For methods with `abortTrigger`, request cancellation is propagated separately. Inspect the specific method: an ordinary request's cancellable path does not establish equivalent multipart support.

[AppHttpClient](../../lib/core/network/app_http_client.dart) combines middleware with `RetryClient`. Retries are disabled by default through `DisableAppHttpRetry`. The optional `DefaultAppHttpRetry` checks for status 503 and the request's HTTP method; it must not be treated as a universal retry policy for all operations. Define client ownership and closure when connecting it to DI.

The initial scaffold has no application-specific APIs, DTOs, repositories, cache or persistence. The following conventions apply when adding the corresponding behavior; demonstration layers are not required merely to complete the directory structure.

### Persistence and compatibility

A server DTO and a local storage format do not have to match. When adding storage, define data ownership, read/write/delete rules, schema compatibility and recovery from a damaged or outdated record. Add versioning and migrations as required by the specific format; the template does not provide a general migration framework.

Sequential operations on local data and the network do not form a shared transaction. Account for intermediate failures when changing their order. An adapter or file name alone does not establish encryption or exclusion of the data from backups.

### Errors

RestApi distinguishes HTTP failures from connection failures; cancellation must not be disguised as an ordinary server error. A mapper/repository may reject an invalid response with `FormatException`/`ArgumentError`. [ExceptionLocalizer](../../lib/core/utils/exception_localizer.dart) localizes errors for the UI; state transitions are described in the [controller guide](controllers.md).

## Verification and completion

The testing scope is defined by the [testing guide](testing.md#normative-requirements): do not add separate tests for the client-server contract, server DTOs or mechanical mapping. Test the data layer only when it contains substantive application logic or a local data source.

For affected pagination logic, select scenarios covering page merging, ordering, duplicates and loading control; for cache/fallback, cover source selection, invalidation and retry; for persistence, cover reading, writing, deletion, local schema compatibility and recovery from errors. Input-validation requirements in production code still apply. Commands and execution restrictions are defined in [AGENTS.md](../../AGENTS.md#verification).
