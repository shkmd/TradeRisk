import Link from"next/link";export default function AuthLayout({children}:{children:React.ReactNode}){return<main className="auth-shell"><Link href="/" className="brand"><span>TR</span>TradeRisk <b>Analytics</b></Link>{children}<p className="auth-legal">Your statements contain sensitive financial data. Files are private, encrypted, and processed only for your workspace.</p></main>}

