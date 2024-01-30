import * as AbsintheSocket from "@absinthe/socket";
import { createAbsintheSocketLink } from "@absinthe/socket-apollo-link";
import { Socket as PhoenixSocket } from "phoenix";

const url = "ws://localhost:4000/socket";

export default createAbsintheSocketLink(
  AbsintheSocket.create(new PhoenixSocket(url))
);
