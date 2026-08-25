/** @jsxImportSource jsx-md */

import { execFileSync } from "node:child_process";
import { readdirSync, readFileSync } from "fs";
import { join, resolve } from "path";
import {
  Badge, Badges, Bold, Center, Code, CodeBlock, Heading, LineBreak,
  List, Item, Paragraph, Raw, Section,
} from "readme/src/components";

const REPO_DIR = resolve(import.meta.dirname);
const testDir = join(REPO_DIR, "test");
const testCount = readdirSync(testDir)
  .filter((f) => f.endsWith(".bats"))
  .map((f) => readFileSync(join(testDir, f), "utf-8"))
  .join("\n")
  .match(/@test "/g)?.length ?? 0;

const heroImage = "./assets/tits-hero.jpg";

function configuredLints(): string[] {
  const miseToml = readFileSync(join(REPO_DIR, "mise.toml"), "utf-8");
  const start = miseToml.indexOf("[_.codebase]");
  if (start === -1) return [];

  const lines = miseToml.slice(start).split("\n");
  const block: string[] = [];
  for (const [index, line] of lines.entries()) {
    if (index > 0 && line.startsWith("[")) break;
    block.push(line);
  }

  const config = block.join("\n");
  const list = config.match(/lint\s*=\s*\[([\s\S]*?)\]/)?.[1] ?? "";
  const configured = [...list.matchAll(/"([^"]+)"/g)].map((match) => match[1]);
  const excluded = new Set(
    [...(config.match(/lint_exclude\s*=\s*\[([\s\S]*?)\]/)?.[1] ?? "").matchAll(/"([^"]+)"/g)]
      .map((match) => match[1]),
  );
  if (!configured.some((rule) => rule.startsWith("@"))) {
    return configured.filter((rule) => !excluded.has(rule));
  }

  const memberships = new Map<string, string[]>();
  let currentGroup = "";
  const groups = execFileSync("codebase", ["lint:groups"], {
    cwd: REPO_DIR,
    encoding: "utf8",
  });
  for (const line of groups.split("\n")) {
    if (line.startsWith("@")) {
      currentGroup = line;
      memberships.set(currentGroup, []);
    } else if (currentGroup && line.startsWith("  ")) {
      memberships.get(currentGroup)?.push(line.trim());
    }
  }

  return [...new Set(configured.flatMap((rule) => memberships.get(rule) ?? [rule]))]
    .filter((rule) => !excluded.has(rule));
}

const lintCount = configuredLints().length;

const readme = (
  <>
    <Center>
      <Raw>{`<img src="${heroImage}" alt="Two tits perched on a log. Get your mind out of the gutter, Andy." width="720" />\n\n`}</Raw>
      <Heading level={1}>tits</Heading>
      <Paragraph><Bold>Bootstrap and doctor an Iris-first agent home.</Bold></Paragraph>
      <Badges>
        <Badge label="tests" value={`${testCount}`} color="brightgreen" />
        <Badge label="lints" value={`${lintCount}`} color="blue" />
        <Badge label="generator" value="agent homes" color="blue" />
        <Badge label="workflows" value="shimmer" color="4a4a4a" />
      </Badges>
    </Center>

    <LineBreak />

    <Section title="What it does">
      <Paragraph>
        <Code>tits</Code>{" creates the smallest useful agent home: files, mise tasks, dependencies, and workflow plumbing for a new agent to orient locally and wake in CI."}
      </Paragraph>
      <Paragraph>
        {"It is deliberately narrower than "}<Code>homes</Code>{": this is the Iris bootstrap/doctor slice, not the whole standard-home roadmap."}
      </Paragraph>
    </Section>

    <Section title="Quick start">
      <CodeBlock lang="bash">{`shiv install tits

tits init --agent iris --home ~/agents/iris/home
cd ~/agents/iris/home
mise welcome
tits doctor --home .`}</CodeBlock>
    </Section>

    <Section title="Generated home surface">
      <Paragraph>
        {"For a brand-new or no-commit home with a clean working tree, "}<Code>init</Code>{" creates the initial "}<Code>bootstrap agent home</Code>{" commit. Use "}<Code>--no-commit</Code>{" to leave files uncommitted."}
      </Paragraph>
      <List>
        <Item><Code>README.tsx</Code>{" / "}<Code>README.md</Code>{" — dynamic home README via KnickKnackLabs/readme"}</Item>
        <Item><Code>notes/status.md</Code>{" — lowercase continuity note"}</Item>
        <Item><Code>mise run welcome</Code>{" — session-start orientation"}</Item>
        <Item><Code>mise run self</Code>{" — self-session placeholder"}</Item>
        <Item><Code>mise run agent:list</Code>{" and "}<Code>agent:identity</Code>{" — shimmer wake contract"}</Item>
        <Item><Code>mise run agent:prepare</Code>{" — idempotent CI preparation hook"}</Item>
        <Item><Code>shimmer workflows:generate</Code>{" output — workflow YAML remains owned by shimmer templates"}</Item>
      </List>
    </Section>

    <Section title="Dependencies">
      <Paragraph>
        <Code>tits</Code>{" depends on "}<Code>shimmer</Code>{" today because shimmer owns workflow generation. When that surface moves into "}<Code>homes</Code>{", this generator should depend on homes instead."}
      </Paragraph>
      <Paragraph>
        {"Generated homes declare the runtime tools their CI/local surface expects, including "}<Code>shimmer</Code>{", "}<Code>sessions</Code>{", "}<Code>secrets</Code>{", "}<Code>emails</Code>{", "}<Code>rudi</Code>{", "}<Code>notes</Code>{", "}<Code>modules</Code>{", "}<Code>codebase</Code>{", and "}<Code>readme</Code>{"."}
      </Paragraph>
    </Section>

    <Section title="Non-goals for the first pass">
      <Paragraph>
        {"No inbox, dashboards, public status extraction, multi-agent discovery, migrations, Obsidian orchestration, or queue tooling. Those belong in "}<Code>homes</Code>{" or later layers."}
      </Paragraph>
    </Section>

    <Section title="Development">
      <CodeBlock lang="bash">{`mise trust
mise install
mise run test
readme build
codebase lint "$PWD"
readme build --check

git diff --check`}</CodeBlock>
    </Section>
  </>
);

console.log(readme);
