import ApolloClient from "apollo-client";
import { InMemoryCache } from "apollo-cache-inmemory";
import absintheSocketLink from "./absinthe-socket-link";

const client = new ApolloClient({
  link: absintheSocketLink,
  cache: new InMemoryCache(),
});

export default client;
