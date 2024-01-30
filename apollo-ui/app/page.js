"use client";

import { Locations } from "./locations";

import {
  useQuery,
  gql,
  ApolloClient,
  InMemoryCache,
  ApolloProvider,
  createHttpLink,
} from "@apollo/client";

const httpLink = createHttpLink({
  uri: "https://flyby-router-demo.herokuapp.com/",
});

const client = new ApolloClient({
  uri: "http://localhost:4000/api",
  cache: new InMemoryCache(),
});

export default function Home() {
  return (
    <ApolloProvider client={client}>
      <Locations />
    </ApolloProvider>
  );
}
