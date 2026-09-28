---
layout: post
title: Universal File Envelope
excerpt: "One wrapper for file signatures and metadata. Is it worth another format?"
description: "A proposal for carrying signatures and metadata around unchanged file bytes, and the compatibility and trust questions it needs to answer."
---

Why should a PDF, a photograph and an HTML file need different ways to carry
and display their signatures?

Signing arbitrary bytes is already solved. The integration is what interests
me: making signatures and metadata travel with the file and show up in
everyday tools.

I'm exploring a **Universal File Envelope (UFE)**: one wrapper for metadata and
signatures, around an otherwise unchanged file. This is an idea for review,
not a finished specification.

## The Idea

Keep the original file intact. Put its type, digest, signatures and extensible
metadata in a common envelope. On disk: an identifying header, an envelope
length, the envelope, then the original file bytes.

The envelope handles verification. The existing parser handles the content.
Unwrapping must recover the original file, byte for byte.

## A Suggested Profile

Here is a possible minimal profile for a photograph. YAML is for readability,
not the wire format; a real encoding might use deterministic CBOR. Hashes,
keys and signatures below are placeholders.

```yaml
profile: ufe/1

payload:
  type: image/jpeg
  length: 827193
  digest: sha256:<payload-hash>

sections:
  provenance:
    digest: sha256:<provenance-hash>
    data:
      org.example.creator: "Example Studio"
  annotations:
    digest: sha256:<annotations-hash>
    data:
      org.example.tags: [photography]
      org.example.viewer.rating: 5

signatures:
  - key: <creator-key>
    covers: [payload]
    value: <creator-signature>
  - key: <publisher-key>
    covers: [payload, provenance]
    value: <publisher-signature>
```

The JPEG bytes sit outside this metadata, unchanged. Each metadata digest
covers the deterministic encoding of its `data` field, not the digest field
itself. Signatures refer to these parts independently.

## One Integration, Many Formats

OS/browser support is the main adoption bet.

Instead of asking every format and application to invent its own integration,
the platform recognises the envelope, verifies its signatures, and exposes the
payload as a bounded file or stream. Existing parsers receive exactly the
bytes they already understand.

**No payload parser needs to change.** The JPEG decoder still decodes JPEG.
The PDF renderer still renders PDF. Neither needs to know UFE exists.

The same mechanism could hand off:

- **JPEG / PNG** to image decoders.
- **MP4 / MP3** to media players.
- **PDF / EPUB** to document readers.
- **HTML** to the browser engine.
- **WASM** to its runtime.
- **ZIP / TAR** to archive readers.

For supported opening paths, this would be transparent: open a photograph,
play a video, view a document. No manual extraction. The platform could also
expose metadata to applications that want it.

That removes a major coordination problem. Codec maintainers don't each have
to adopt UFE; one platform integration could serve many existing formats and
applications. Signing becomes infrastructure rather than a per-format feature.

This is not automatic compatibility with today's software. A wrapped JPEG is
still not a raw JPEG. Unsupported paths need explicit unwrapping or an adapter;
platform support must cover the actual file access, not just recognise a filename.

## Sign Sections, Not Everything

The profile has two independent signatures:

- The **creator** signs the payload.
- The **publisher** signs the payload and provenance together.

Changing a personal tag leaves both valid. Changing provenance invalidates the
publisher's signature, but not the creator's. Changing the payload invalidates
both. An archive could additionally sign all three sections to authenticate
that particular snapshot.

This only works if scopes are cryptographically bound. Signatures would cover
a canonical manifest binding the profile/version, scope, unique section
identifiers, relevant types and lengths, and content hashes. Verification must recompute
those hashes from the stored bytes, not trust the values in the envelope.

The interface must show **what was signed**, not put a reassuring checkmark on
the entire file when only its payload was covered.

## Arbitrary Keys, Optional Meaning

Applications can add namespaced keys such as `org.example.viewer.rating`
without changing JPEG, PDF or the envelope's core specification.

**Unknown optional keys are ignored.** A viewer that doesn't understand a
rating or editing-history field can still open the payload. It doesn't have to
understand every application's metadata to understand the file.

Ignored doesn't mean removed from verification. Unknown data inside a signed
section still contributes to its hash. Unsupported signature algorithms or
required security semantics must be reported as unsupported, never silently
treated as verified.

## Make Signing Ordinary

The useful change isn't new cryptography. It's making existing cryptography
available through the same file operations everywhere.

A file manager could show which keys signed which parts of a photograph, a
research PDF or a saved HTML application through one interface. The evidence
would travel with the file through email, a USB drive or a download, instead
of requiring the recipient to find a detached signature and a separate workflow.

One implementation of **sign, inspect, verify and unwrap** could serve all of
these formats. OS/browser integration could make verification an ordinary file
property rather than a specialist task. The decoder stays concerned with
content; the platform handles the cryptographic machinery.

Integrity still isn't trust. A valid signature doesn't establish who owns the
key, whether provenance claims are true, or whether an application is safe.
Trust stores, pinned keys and other identity systems remain separate. UFE
would carry evidence, not decide whom everyone must trust.

## Is It Worth Building?

I'd like criticism on three points:

1. **Already solved?** Would an existing container or a ZIP with a signed
   manifest provide the same useful abstraction?
2. **Does the platform boundary hold?** Can transparent handoff preserve
   seeking, memory-mapped access, type checks and browser security rules?
3. **Can it stay small?** Can section scopes, extension rules and strict parser
   limits remain simple enough to implement and audit?

I'd start with a tiny pack/verify/unwrap tool across JPEG, MP4, PDF and HTML:
recover identical bytes, detect changes to signed sections, and preserve
signatures when unrelated annotations change. Then test one real platform
handoff. Leave encryption, embedded resources and permissions for later.

The goal is less duplicated machinery. If existing tools can deliver that,
I'd rather use them.
