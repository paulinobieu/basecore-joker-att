import { navigation } from "@app/router/routes";
import { Link } from "./components/Link";

export function Navbar() {
  return (
    <nav className="flex flex-col items-center">
      {navigation.map((entry) => (
        <Link key={entry.route} entry={entry} />
      ))}
    </nav>
  );
}
