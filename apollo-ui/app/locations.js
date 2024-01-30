"use client";

import { gql, useQuery } from "@apollo/client";

const dataQuery = gql`
  query {
    menuItems {
      id
      name
    }
  }
`;

export const Locations = () => {
  const { data, error, loading } = useQuery(dataQuery);

  console.log("🚀 ~ Locations ~ error:", error);
  console.log("🚀 ~ Locations ~ data:", data);

  if (loading) return "LOADING";
  if (error) return "error";

  return (
    <div>
      <ul>
        {data.menuItems &&
          data.menuItems.map((l) => <li key={l.id}>{l.name}</li>)}
      </ul>
    </div>
  );
};
