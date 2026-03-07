import React, { useState, useEffect } from "react";
import "../../static/css/custom.css";
import "../../static/css/news.css";
import { useTranslation } from "react-i18next";

const NewsList = ({ news }) => {
  const { t, i18n } = useTranslation();
  const currentLanguage = i18n.language;

   const getPlaceholderUrl = (seed, type = 'left') => {
    return `https://picsum.photos/600/400?random=${seed}-${type}`;
  };

  // Use placeholder service URLs or CSS gradients
  const DEFAULT_PLACEHOLDER_LEFT = getPlaceholderUrl(1, 'left');
  const DEFAULT_PLACEHOLDER_RIGHT = getPlaceholderUrl(2, 'right');


  const [bgImageLeft, setBgImageLeft] = useState(DEFAULT_PLACEHOLDER_LEFT);
  const [bgImageRight, setBgImageRight] = useState(DEFAULT_PLACEHOLDER_RIGHT);

  // Helper function to validate and format image URL
  const getImageUrl = (imageUrl, fallback) => {
    if (!imageUrl) return fallback;
    
    // Handle relative URLs from backend
    if (imageUrl.startsWith('/media/') || imageUrl.startsWith('/static/')) {
      return `${window.location.origin}${imageUrl}`;
    }
    
    // Handle full URLs
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // Default to fallback for invalid URLs
    return fallback;
  };

  useEffect(() => {
    if (news && news.length > 0) {
      const leftImage = getImageUrl(news[0].image_left, DEFAULT_PLACEHOLDER_LEFT);
      const rightImage = getImageUrl(news[0].image_right, DEFAULT_PLACEHOLDER_RIGHT);
      
      setBgImageLeft(leftImage);
      setBgImageRight(rightImage);
    } else {
      setBgImageLeft(DEFAULT_PLACEHOLDER_LEFT);
      setBgImageRight(DEFAULT_PLACEHOLDER_RIGHT);
    }
  }, [news]);
  
  return (
    <>
      {!news || news.length <= 0 ? (
        <div>
          <section className="row tm-section-mb tm-section-2">
            <div className="col-md-12 tm-section-2-inner">
              <div className="tm-section-2-left">
                <div 
                  className="tm-img-container tm-img-container-1"
                  style={{ backgroundImage: `url('${bgImageLeft}')` }}
                  role="img"
                  aria-label="Placeholder image left"
                ></div>
                <div 
                  className="tm-img-container tm-img-container-2"
                  style={{ backgroundImage: `url('${bgImageRight}')` }}
                  role="img"
                  aria-label="Placeholder image right"
                ></div>
              </div>
              <div className="tm-section-2-right tm-bg-primary">
                <div className="tm-section-2-text">
                  <h2 className="tm-section-2-header tm-mb-45 text-center">
                    {t("No news yet!")}
                  </h2>
                </div>
              </div>
            </div>
          </section>
        </div>
      ) : (
        news.map((newsItem) => (
          <div key={newsItem.pk} className="mt-3">
            <section className="row tm-section-mb tm-section-2">
              <div className="col-md-12 tm-section-2-inner">
                <div className="tm-section-2-left">
                  <div 
                    className="tm-img-container tm-img-container-1"
                    style={{ 
                      backgroundImage: `url('${getImageUrl(newsItem.image_left, DEFAULT_PLACEHOLDER_LEFT)}')` 
                    }}
                    role="img"
                    aria-label={newsItem[`title_${currentLanguage}`] || "News image left"}
                  ></div>
                  <div 
                    className="tm-img-container tm-img-container-2"
                    style={{ 
                      backgroundImage: `url('${getImageUrl(newsItem.image_right, DEFAULT_PLACEHOLDER_RIGHT)}')` 
                    }}
                    role="img"
                    aria-label={newsItem[`title_${currentLanguage}`] || "News image right"}
                  ></div>
                </div>
                <div className="tm-section-2-right tm-bg-primary">
                  <div className="tm-section-2-text tm-skew-container">
                    <div className="tm-skew-content">
                    <h2 className="tm-section-2-header tm-mb-45 text-center">
                      {newsItem[`title_${currentLanguage}`]}
                    </h2>
                    <h4 className="text-center mt-2">
                      {newsItem[`header_${currentLanguage}`]}
                    </h4>
                    <p>{newsItem[`description_${currentLanguage}`]}</p>
                    <p>{newsItem[`features_${currentLanguage}`]}</p>
                    <p>
                      {t("Posted on: ")}
                      {newsItem.posted_on}
                    </p>
                    </div>
                  </div>
                </div>
              </div>
            </section>
          </div>
        ))
      )}
    </>
  );
};

export default NewsList;