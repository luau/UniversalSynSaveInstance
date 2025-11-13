import * as React from "react"
import PropTypes from "prop-types"
import { useStaticQuery, graphql } from "gatsby"

const Seo = ({ description, lang, meta, title, articles }) => {
  const { site } = useStaticQuery(graphql`
    query {
      site {
        siteMetadata {
          title
          description
          social {
            twitter
          }
        }
      }
    }
  `)

  const metaDescription = description || site.siteMetadata.description
  const defaultTitle = site.siteMetadata?.title

  const actualTitle = defaultTitle ? `${title} | ${defaultTitle}` : title

  return (
    <>
      <html lang={lang} />
      <title>{actualTitle}</title>
      {articles.map(headline => (
        <script key={headline} type="application/ld+json">
          {JSON.stringify([
            {
              "@context": "https://darklua.com",
              "@type": "Article",
              headline,
              image: [],
              author: [
                {
                  "@type": "Person",
                  name: "jeparlefrancais",
                },
                {
                  "@type": "Organization",
                  name: "Sea of Voices",
                  url: "https://github.com/seaofvoices",
                },
              ],
            },
          ])}
        </script>
      ))}
      <meta name="description" content={metaDescription} />
      <meta name="og:title" content={actualTitle} />
      <meta name="og:description" content={metaDescription} />
      <meta name="og:type" content="website" />
      <meta
        name="twitter:card"
        content={site.siteMetadata?.social?.twitter || ``}
      />
      <meta
        name="twitter:creator"
        content={site.siteMetadata?.social?.twitter || ``}
      />
      <meta name="twitter:description" content={metaDescription} />
      <meta name="twitter:title" content={actualTitle} />
      {meta.map(({ name, content }) => (
        <meta key={name} name={name} content={content} />
      ))}
    </>
  )
}

Seo.defaultProps = {
  lang: `en`,
  meta: [],
  description: ``,
  articles: [],
}

Seo.propTypes = {
  description: PropTypes.string,
  lang: PropTypes.string,
  meta: PropTypes.arrayOf(PropTypes.object),
  title: PropTypes.string.isRequired,
}

export default Seo
