import type{Metadata}from"next";import"./globals.css";export const metadata:Metadata={title:{default:"TradeRisk Analytics",template:"%s · TradeRisk Analytics"},description:"Private, auditable trading performance and risk analytics."};export default function Layout({children}:{children:React.ReactNode}){return<html lang="en"><body>{children}</body></html>}

