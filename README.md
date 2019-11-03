# Postal Service API

[![CircleCI](https://circleci.com/gh/jnormington/postal-service.svg?style=svg&circle-token=c2e5836935dd887907645962cff2cb61ff000e03)](https://circleci.com/gh/jnormington/postal-service)

# Development

## Run tests

```sh
bundle
bundle exec rspec
```

## Running the service locally

Running the following command for running the backend API. Which will start the API on port 9292 by default

```sh
cp config.json.example config.json
bundle exec rackup
```

Open the following HTML file in `frontend/index.html` in your favourite browser and away you go with the form


# Endpoints

| HTTP Method | Path                | Response Type      | Code  | Response
| ----------- | ------------------- | ------------------ | ----- | ---------------------------------------------------------------------------- |
| GET         | /ping               | `text/plain`       | 200   | PONG                                                                         |
| GET         | /postcodes/:postcode| `application/json` | 200   | { "result": {"supported_lsoa": false, "lsoa": "Barking and Dagenham 019E" }} |
| GET         | /postcodes/:postcode| `application/json` | 4/5xx | { "err": "ErrPostcodeNotValid", "message": "postcode not valid" }}           |

# Improvements

- Add linter to CI workflow
- Adding a logger to log flows through out the code
- Add middleware for a requestId which is passed through the services and returned to the client (for transversing the logs easily between services)
- As the front-end is seperate from the backend service we would implement a contract test to ensure the contract isn't broken (other more heavy wait tests would also give us this) but the contracts give just enough
