import { main } from "effection";
import { createSimulationServer, Server } from "@simulacrum/server";
import { auth0 } from "@simulacrum/auth0-simulator";
import { createClient } from "@simulacrum/client";

const port = Number(process.env.PORT) ?? 4000; // port for the main simulation service

// effection is a structured concurrency library and this will help us handle errors and shutting down the server gracefully
main(function* () {
  let server: Server = yield createSimulationServer({
    seed: 1,
    port,
    simulators: { auth0 },
  });

  let url = `http://localhost:${server.address.port}`;

  console.log(`simulation server running at ${url}`);

  let client = createClient(url);

  let simulation = yield client.createSimulation("auth0", {
    options: {
      audience: "http://localhost:20100",
      scope: "openid profile email",
      clientID: "00000000000000000000000000000000",
    },
    services: {
      auth0: {
        port: 4400, // port for the auth0 service itself
      },
    },
  });

  console.log(`auth0 service running at ${simulation.services[0].url}`);
  console.log(simulation);
  yield;
});
