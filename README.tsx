/** @jsxImportSource jsx-md */

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

const logo = String.raw`
        (\_/)
   (\_/) ( o_o)   tits
   ( o_o) / >*     agent homes hatch here
   / >bird
`;

const readme = (
  <>
    <Center>
      <Raw>{`<pre>${logo}</pre>\n\n`}</Raw>
      <Heading level={1}>tits</Heading>
      <Paragraph><Bold>Bootstrap and doctor an Iris-first agent home.</Bold></Paragraph>
      <Badges>
        <Badge label="tests" value={`${testCount}`} color="brightgreen" />
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
        {"Generated homes declare the runtime tools their CI/local surface expects, including "}<Code>shimmer</Code>{", "}<Code>sessions</Code>{", "}<Code>secrets</Code>{", "}<Code>emails</Code>{", "}<Code>rudi</Code>{", "}<Code>notes</Code>{", "}<Code>modules</Code>{", and "}<Code>codebase</Code>{"."}
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
codebase lint:mise-settings "$PWD"
codebase lint:gum-table "$PWD"
codebase lint:shellcheck "$PWD"`}</CodeBlock>
    </Section>
  </>
);

console.log(readme);
