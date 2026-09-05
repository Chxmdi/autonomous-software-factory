"use client";
import { useState } from "react";

export function LocalDateTimeInput({ name, id, required = true }: { name: string; id: string; required?: boolean }) {
  const [value,setValue] = useState("");
  let iso = "";
  if (value) { const date = new Date(value); if (!Number.isNaN(date.getTime())) iso = date.toISOString(); }
  return <><input id={id} type="datetime-local" value={value} onChange={e => setValue(e.target.value)} required={required}/><input type="hidden" name={name} value={iso}/></>;
}
